#!/bin/bash

# ========================================
# iHeaven P2P 功能集成测试脚本
# 测试P2P网络连接、状态、拓扑和中继功能
# ========================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  iHeaven P2P 功能集成测试${NC}"
echo -e "${BLUE}========================================${NC}"

# 检查服务是否运行
echo -e "${YELLOW}🔍 检查服务状态...${NC}"

if ! curl -f http://localhost:8080/api/v1/health > /dev/null 2>&1; then
    echo -e "${RED}❌ 后端服务未运行，请先启动服务${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 后端服务运行正常${NC}"

# 测试1: P2P网络状态
echo -e "${BLUE}📡 测试1: P2P网络状态${NC}"
echo -e "${YELLOW}获取P2P状态信息...${NC}"

P2P_STATUS=$(curl -s http://localhost:8080/api/v1/p2p/status)
echo -e "${GREEN}P2P状态响应:${NC}"
echo "$P2P_STATUS" | jq '.' 2>/dev/null || echo "$P2P_STATUS"

# 测试2: 全球网络状态
echo -e "${BLUE}🌐 测试2: 全球网络状态${NC}"
echo -e "${YELLOW}获取全球网络状态...${NC}"

GLOBAL_STATUS=$(curl -s http://localhost:8080/api/v1/global/status)
echo -e "${GREEN}全球网络状态响应:${NC}"
echo "$GLOBAL_STATUS" | jq '.' 2>/dev/null || echo "$GLOBAL_STATUS"

# 测试3: 网络拓扑
echo -e "${BLUE}🗺️  测试3: 网络拓扑${NC}"
echo -e "${YELLOW}获取网络拓扑信息...${NC}"

TOPOLOGY=$(curl -s http://localhost:8080/api/v1/global/topology)
echo -e "${GREEN}网络拓扑响应:${NC}"
echo "$TOPOLOGY" | jq '.' 2>/dev/null || echo "$TOPOLOGY"

# 测试4: 中继节点状态
echo -e "${BLUE}🔄 测试4: 中继节点状态${NC}"
echo -e "${YELLOW}获取中继节点信息...${NC}"

RELAY_STATUS=$(curl -s http://localhost:8080/api/v1/global/relay)
echo -e "${GREEN}中继节点状态响应:${NC}"
echo "$RELAY_STATUS" | jq '.' 2>/dev/null || echo "$RELAY_STATUS"

# 测试5: 档案同步端点
echo -e "${BLUE}📋 测试5: 档案同步端点${NC}"
echo -e "${YELLOW}测试GET同步端点...${NC}"

SYNC_GET=$(curl -s http://localhost:8080/api/v1/p2p/items/sync)
echo -e "${GREEN}GET同步响应:${NC}"
echo "$SYNC_GET" | jq '.' 2>/dev/null || echo "$SYNC_GET"

echo -e "${YELLOW}测试POST同步端点...${NC}"
SYNC_POST=$(curl -s -X POST http://localhost:8080/api/v1/p2p/items/sync)
echo -e "${GREEN}POST同步响应:${NC}"
echo "$SYNC_POST" | jq '.' 2>/dev/null || echo "$SYNC_POST"

# 测试6: 主动同步端点
echo -e "${BLUE}🔄 测试6: 主动同步端点${NC}"
echo -e "${YELLOW}测试主动同步...${NC}"

ACTIVE_SYNC=$(curl -s -X POST http://localhost:8080/api/v1/p2p/sync/active)
echo -e "${GREEN}主动同步响应:${NC}"
echo "$ACTIVE_SYNC" | jq '.' 2>/dev/null || echo "$ACTIVE_SYNC"

# 测试7: 节点发现
echo -e "${BLUE}🔍 测试7: 节点发现${NC}"
echo -e "${YELLOW}触发节点发现...${NC}"

DISCOVER=$(curl -s -X POST http://localhost:8080/api/v1/p2p/discover)
echo -e "${GREEN}节点发现响应:${NC}"
echo "$DISCOVER" | jq '.' 2>/dev/null || echo "$DISCOVER"

# 测试8: 创建测试档案
echo -e "${BLUE}📝 测试8: 创建测试档案${NC}"
echo -e "${YELLOW}创建测试档案...${NC}"

TEST_ITEM='{
    "tier": "test",
    "meta": {
        "name": "P2P集成测试档案",
        "description": "用于测试P2P同步功能",
        "tags": ["测试", "P2P", "集成"]
    },
    "access": "public"
}'

CREATE_RESPONSE=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d "$TEST_ITEM" \
    http://localhost:8080/api/v1/p2p/items/)

echo -e "${GREEN}创建档案响应:${NC}"
echo "$CREATE_RESPONSE" | jq '.' 2>/dev/null || echo "$CREATE_RESPONSE"

# 测试9: 获取所有档案
echo -e "${BLUE}📋 测试9: 获取所有档案${NC}"
echo -e "${YELLOW}获取档案列表...${NC}"

ITEMS_RESPONSE=$(curl -s http://localhost:8080/api/v1/p2p/items/)
echo -e "${GREEN}档案列表响应:${NC}"
echo "$ITEMS_RESPONSE" | jq '.' 2>/dev/null || echo "$ITEMS_RESPONSE"

# 测试10: 检查Docker容器状态
echo -e "${BLUE}🐳 测试10: Docker容器状态${NC}"
echo -e "${YELLOW}检查容器运行状态...${NC}"

if docker ps | grep -q "iheaven-node"; then
    echo -e "${GREEN}✅ iheaven-node 容器运行正常${NC}"
    echo -e "${BLUE}容器详细信息:${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep iheaven
else
    echo -e "${RED}❌ iheaven-node 容器未运行${NC}"
fi

# 测试11: 检查网络连接
echo -e "${BLUE}🌐 测试11: 网络连接状态${NC}"
echo -e "${YELLOW}检查网络端口监听...${NC}"

if netstat -an 2>/dev/null | grep -q ":8080.*LISTEN"; then
    echo -e "${GREEN}✅ HTTP API端口(8080)监听正常${NC}"
else
    echo -e "${RED}❌ HTTP API端口(8080)未监听${NC}"
fi

if netstat -an 2>/dev/null | grep -q ":9080.*LISTEN"; then
    echo -e "${GREEN}✅ P2P网络端口(9080)监听正常${NC}"
else
    echo -e "${YELLOW}⚠️  P2P网络端口(9080)未监听（可能正常）${NC}"
fi

# 测试12: 检查日志
echo -e "${BLUE}📋 测试12: 服务日志检查${NC}"
echo -e "${YELLOW}检查最近的日志...${NC}"

if docker logs --tail 20 iheaven-node 2>/dev/null | grep -q "P2P"; then
    echo -e "${GREEN}✅ 发现P2P相关日志${NC}"
    echo -e "${BLUE}最近的P2P日志:${NC}"
    docker logs --tail 10 iheaven-node 2>/dev/null | grep -i "p2p\|sync\|network" || echo "未找到相关日志"
else
    echo -e "${YELLOW}⚠️  未发现P2P相关日志${NC}"
fi

# 总结
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  🎯 测试完成总结${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "${GREEN}✅ 已完成的测试:${NC}"
echo -e "  - P2P网络状态检查"
echo -e "  - 全球网络状态检查"
echo -e "  - 网络拓扑信息获取"
echo -e "  - 中继节点状态检查"
echo -e "  - 档案同步端点测试"
echo -e "  - 主动同步功能测试"
echo -e "  - 节点发现功能测试"
echo -e "  - 档案创建和获取测试"
echo -e "  - Docker容器状态检查"
echo -e "  - 网络端口监听检查"
echo -e "  - 服务日志分析"

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}🎉 P2P功能集成测试完成！${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}💡 提示: 如果发现任何问题，请检查日志和网络配置${NC}"
echo -e "${YELLOW}🔗 前端访问: http://localhost:3000${NC}"
echo -e "${YELLOW}🔗 后端API: http://localhost:8080${NC}"
echo -e "${YELLOW}🔗 P2P状态: http://localhost:8080/api/v1/p2p/status${NC}"
