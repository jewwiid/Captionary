# CLAUDE_MCP.md — Model Context Protocol setup for Captionary

## Why this matters
We use **MCP** to give Claude reliable, up-to-date context from:
1. Our Git repos (code & docs) via **GitMCP**.
2. **Apple Developer Documentation** (SwiftUI, UIKit, StoreKit, etc.) via **apple-doc-mcp**.

This ensures Claude references real APIs and codebases when building or refactoring.

---

## Prerequisites
- Claude Desktop or another MCP-capable IDE (e.g. Cursor, Replit Cloud Code).
- Node.js or Docker (depending on server setup).
- Git repos you want Claude to read (Captionary, templates, etc.).

---

## Option A — Hosted Git Context (gitmcp.io)
1. Visit [https://gitmcp.io](https://gitmcp.io).
2. Connect any public GitHub repo (e.g., your Captionary repo).
3. GitMCP provisions an MCP endpoint Claude can read from.
4. Claude can now browse files, docs, and decisions for grounding.

Use this when you need a fast setup and don’t require privacy control.

---

## Option B — Self-host GitMCP
Open-source version: [https://github.com/idosal/git-mcp](https://github.com/idosal/git-mcp)

Run locally or on your server:
```bash
npx git-mcp --repo https://github.com/<your-org>/<captionary-repo>
```
Claude can then query the repo context via MCP.

---

## Apple Docs MCP (SwiftUI / StoreKit / UIKit)
Choose one of the following servers:
- [MightyDillah/apple-doc-mcp](https://github.com/MightyDillah/apple-doc-mcp)
- [kimsungwhee/apple-docs-mcp](https://github.com/kimsungwhee/apple-docs-mcp)
- [bbssppllvv/apple-docs-mcp-server](https://github.com/bbssppllvv/apple-docs-mcp-server)

Each provides search and retrieval across Apple Developer docs and WWDC transcripts.

---

## Claude Configuration Example
Add this to your Claude MCP config file:
```json
{
  "mcpServers": {
    "gitmcp-captionary": {
      "command": "npx",
      "args": ["git-mcp", "--repo", "https://github.com/<your-org>/<captionary>"],
      "env": { "GITHUB_TOKEN": "ghp_xxx_if_needed" }
    },
    "apple-docs-mcp": {
      "command": "npx",
      "args": ["apple-docs-mcp", "--port", "7420"]
    }
  }
}
```

---

## Always-Reference Rules
Before generating SwiftUI or backend code, Claude must:
1. Query **Apple Docs MCP** for API references (NavigationStack, StoreKit2, etc.).
2. Query **GitMCP** for local context (/Views, /Services, /docs).
3. Cite both sources inline.
4. Refuse to proceed if MCP is disconnected.

---

## Claude Prompts (examples)
### SwiftUI Screen Implementation
```
Use Apple Docs MCP and GitMCP first.

Task: Implement PaywallView (SwiftUI) with StoreKit2.
Steps:
1. Fetch latest API references for StoreKit2.
2. Read local /Views/PaywallView.swift and /Services/PurchaseManager.swift.
3. Propose minimal diff with Apple doc citations.
4. If sources unavailable, pause and request reconnection.
```

### Edge Function Example
```
Use Apple Docs MCP (URLSession async/await).
Use GitMCP (/Services/EdgeAPI.swift).
Write generate(request:) with async handling.
Cite both sources.
```

---

## Recommended Workflow
1. Attach both servers (GitMCP + Apple Docs MCP).
2. Start each Claude task with “Use MCP references first.”
3. Require citations (file paths or API doc URLs).
4. Keep /docs/DECISIONS.md for persistent memory via GitMCP.

---

## Troubleshooting
- GitMCP connection errors → check repo visibility and token.
- Apple Docs MCP timeout → switch to another server.
- Always review security: MCP grants tool access to local repos.

---

## References
- [gitmcp.io](https://gitmcp.io)
- [apple-doc-mcp (MightyDillah)](https://github.com/MightyDillah/apple-doc-mcp)
- [MCP Specification](https://modelcontextprotocol.io/)
