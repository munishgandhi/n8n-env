# n8n-MCP Tools Documentation

This document contains essential n8n-MCP tool examples with real usage samples from the Helix research project.

## Quick Health Check (Copy-Paste Ready)

**Verify n8n-MCP is working through Claude Code:**
```python
# Test 1: Database statistics (what we actually use in agents)
mcp__n8n-mcp__get_database_statistics()
# Expected: {"totalNodes": 534, "statistics": {"aiTools": 268, "triggers": 108}}

# Test 2: List available tools 
mcp__n8n-mcp__n8n_list_available_tools()
# Expected: {"success": true, "data": {"tools": [...], "apiConfigured": true}}

# Test 3: Search nodes (environment-specific)
mcp__n8n-mcp__search_nodes(query="webhook", limit=2)
# Expected: Returns webhook-related nodes
```


## Tools Status
**Total Available: 36 tools**
**Documented in this file: 5 tools** (tools actually used in Helix project)
**TODO: 31 tools** (marked below for future documentation)

### Documented Tools (Used in Project)
- ✅ tools_documentation
- ✅ search_nodes  
- ✅ get_database_statistics
- ✅ n8n_list_available_tools
- ✅ n8n_diagnostic

### TODO Tools (31 remaining)
- 🔲 Node Discovery (8): list_nodes, get_node_info, list_ai_tools, get_node_documentation, get_node_essentials, search_node_properties, get_property_dependencies, get_node_as_tool_info
- 🔲 Template Tools (4): list_node_templates, get_template, search_templates, get_templates_for_task
- 🔲 Validation Tools (6): validate_node_operation, validate_node_minimal, validate_workflow, validate_workflow_connections, validate_workflow_expressions, list_tasks
- 🔲 Workflow Management (8): n8n_create_workflow, n8n_get_workflow, n8n_get_workflow_details, n8n_get_workflow_structure, n8n_get_workflow_minimal, n8n_update_full_workflow, n8n_update_partial_workflow, n8n_delete_workflow
- 🔲 Execution Management (3): n8n_get_execution, n8n_list_executions, n8n_delete_execution
- 🔲 System Tools (2): n8n_health_check, n8n_trigger_webhook_workflow

---

## Tools Actually Used in Helix Project

### 1. tools_documentation
**Purpose:** Get comprehensive documentation for MCP tools

**Call Examples:**
```json
# Basic documentation
{"name": "tools_documentation", "arguments": {}}

# Specific topic documentation  
{"name": "tools_documentation", "arguments": {"topic": "overview"}}
```

**Real Response from Project:**
```
# n8n MCP Tools Reference

## Standard Workflow Pattern
1. **Find** nodes: search_nodes({query: "notion"}) - Search for Notion integration
2. **Configure** nodes: get_node_info("nodes-base.notion") - Get Notion node schema
3. **Validate** workflow: validate_workflow(workflow) - Check before deployment

## Tool Categories  
- Discovery Tools: search_nodes, list_nodes, list_ai_tools
- Configuration Tools: get_node_essentials, get_node_info
- Validation Tools: validate_node_minimal, validate_workflow
- n8n API Tools: n8n_create_workflow, n8n_get_execution
```

### 2. search_nodes
**Purpose:** Find nodes relevant to your integrations (Notion, Gmail, etc.)

**Call Example:**
```json
{"name": "search_nodes", "arguments": {"query": "webhook", "limit": 2}}
```

**Real Response from Project:**
```json
{
  "query": "webhook",
  "results": [
    {
      "nodeType": "nodes-base.activeCampaignTrigger",
      "displayName": "ActiveCampaign Trigger",
      "description": "Handle ActiveCampaign events via webhooks",
      "category": "trigger"
    },
    {
      "nodeType": "nodes-base.acuitySchedulingTrigger", 
      "displayName": "Acuity Scheduling Trigger",
      "description": "Handle Acuity Scheduling events via webhooks",
      "category": "trigger"
    }
  ],
  "totalCount": 2
}
```

### 3. get_database_statistics
**Purpose:** Verify MCP connection and get n8n node counts

**Call Example:**
```json
{"name": "get_database_statistics", "arguments": {}}
```

**Real Response from Project:**
```json
{
  "totalNodes": 534,
  "statistics": {
    "aiTools": 268,
    "triggers": 108,
    "versionedNodes": 138,
    "nodesWithDocumentation": 470,
    "documentationCoverage": "88%",
    "uniquePackages": 2,
    "uniqueCategories": 5
  },
  "packageBreakdown": [
    {"package": "@n8n/n8n-nodes-langchain", "nodeCount": 98},
    {"package": "n8n-nodes-base", "nodeCount": 436}
  ]
}
```

### 4. n8n_list_available_tools
**Purpose:** See which n8n API tools are available for workflow management

**Call Example:**
```json
{"name": "n8n_list_available_tools", "arguments": {}}
```

**Real Response from Project:**
```json
{
  "success": true,
  "data": {
    "tools": [
      {
        "category": "Workflow Management",
        "tools": [
          {"name": "n8n_create_workflow", "description": "Create new workflows"},
          {"name": "n8n_get_workflow", "description": "Get workflow by ID"},
          {"name": "n8n_update_workflow", "description": "Update existing workflows"}
        ]
      },
      {
        "category": "Execution Management", 
        "tools": [
          {"name": "n8n_get_execution", "description": "Get execution details"},
          {"name": "n8n_list_executions", "description": "List executions with filters"}
        ]
      }
    ],
    "apiConfigured": true,
    "configuration": {
      "apiUrl": "http://localhost:5678",
      "timeout": 30000
    }
  }
}
```

### 5. n8n_diagnostic
**Purpose:** Check n8n API connectivity and configuration status

**Call Example:**
```json
{"name": "n8n_diagnostic", "arguments": {}}
```

**Expected Response:**
```json
{
  "success": true,
  "status": "healthy",
  "apiConfigured": true,
  "connectivity": "working",
  "configuration": {
    "apiUrl": "http://localhost:5678",
    "authenticated": true
  }
}
```

---

## TODO: Remaining 31 Tools

The following tools are available but not yet documented with examples. Add samples as needed for future Helix project work.

### Node Discovery Tools (TODO - 8 tools)

**🔲 list_nodes** - List nodes with filtering by category, package, or type
```json
// TODO: Add example with {"category": "trigger", "limit": 10}
```

**🔲 get_node_info** - Get complete node schema (useful for Notion, Gmail setup)
```json
// TODO: Add example with {"nodeType": "nodes-base.notion"}
```

**🔲 list_ai_tools** - List all AI-capable nodes  
**🔲 get_node_documentation** - Get readable docs with examples  
**🔲 get_node_essentials** - Get essential properties only (faster than get_node_info)  
**🔲 search_node_properties** - Search for specific properties within a node  
**🔲 get_property_dependencies** - Analyze property visibility dependencies  
**🔲 get_node_as_tool_info** - How to use any node as AI tool  

### Template Tools (TODO - 4 tools)

**🔲 list_node_templates** - Find templates using specific nodes  
**🔲 get_template** - Get complete workflow JSON by ID  
**🔲 search_templates** - Search workflow templates by keyword  
**🔲 get_templates_for_task** - Curated templates by task type  

### Validation Tools (TODO - 6 tools)

**🔲 validate_node_operation** - Full validation with operation awareness  
**🔲 validate_node_minimal** - Quick validation of required fields only  
**🔲 validate_workflow** - Complete workflow validation including connections  
**🔲 validate_workflow_connections** - Check workflow connections only  
**🔲 validate_workflow_expressions** - Validate n8n expressions syntax  
**🔲 list_tasks** - List common task templates  

### Workflow Management Tools (TODO - 8 tools)

**🔲 n8n_create_workflow** - Create new workflows  
**🔲 n8n_get_workflow** - Get workflow by ID (useful for Helix workflow: uUBVhsiEXzQm5eOv)  
**🔲 n8n_get_workflow_details** - Get detailed workflow info with stats  
**🔲 n8n_get_workflow_structure** - Get simplified workflow structure  
**🔲 n8n_get_workflow_minimal** - Get minimal workflow info  
**🔲 n8n_update_full_workflow** - Full workflow update  
**🔲 n8n_update_partial_workflow** - Update workflows using diff operations  
**🔲 n8n_delete_workflow** - Delete workflows  

### Execution Management Tools (TODO - 3 tools)

**🔲 n8n_get_execution** - Get execution details (useful for Helix execution analysis)  
**🔲 n8n_list_executions** - List executions with filters (for Helix workflow monitoring)  
**🔲 n8n_delete_execution** - Delete execution records  

### System Tools (TODO - 2 tools)

**🔲 n8n_health_check** - Check API connectivity  
**🔲 n8n_trigger_webhook_workflow** - Trigger workflow execution  

---

## Key Findings

✅ **All 36 tools available** through Claude Code MCP integration  
✅ **5 tools documented** with real usage examples from Helix project  
✅ **Copy-paste health check** available for quick MCP verification  
✅ **Direct MCP calls** - no Docker containers needed  
✅ **534 total n8n nodes** available with 88% documentation coverage  
✅ **Environment-specific examples** (webhook, notion) instead of generic samples  

Next: Document additional tools as needed for Notion integration, Gmail automation, and Helix workflow management.