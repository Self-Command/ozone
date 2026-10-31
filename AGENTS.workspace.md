# AGENTS.workspace.md — ozone 企业叠加规则

> 本文件由工作区维护，补充上游 `AGENTS.md`，不替代它。
> 开始任务前依次阅读：工作区根 `AGENTS.md` → 本文件 → 上游 `AGENTS.md`。
> 规则冲突、需要改变策略或发现阻塞时，必须停止并向用户提问，等待裁决。

## 1. 环境

- Node `24.x`；本机使用 `H:\Dev\Tools\node-24.22.1`。
- 包管理器使用 Corepack Yarn 4.8.1；不依赖全局 Yarn。
- 本地联调需要 atproto `dev-env` 与 `NEXT_PUBLIC_OZONE_SERVICE_DID`。

```bash
export PATH="/h/Dev/Tools/node-24.22.1:$PATH"
cd repos/ozone
corepack yarn install
```

## 2. 流程

- 任何行为、权限、接口、依赖变更，先有 OpenSpec change 并通过用户审批。
- 审核能力的后端在 `repos/atproto/packages/ozone`；只改 UI 不算完成。
- 先用 CodeGraph 定位页面、组件、`lib/client.ts`、`lib/server-config.ts` 与相关服务端 handler。
- 动态注册、字符串拼接、权限映射等盲区必须用 `rg` 复核，结论以 type-check / 测试为准（见工作区根 `AGENTS.md` 第 4 节）。
- 小步实现；每步运行类型检查与相关测试。

## 3. 权限与安全

- `lib/server-config.ts` 的角色映射只控制 UI 展示，**不是安全边界**。
- 所有处置、标签、邮件、团队管理动作必须由 Ozone 服务端再次校验角色与资源归属。
- 新增权限位时同步更新：UI `ServerConfig.permissions`、服务端角色检查、权限测试。
- `NEXT_PUBLIC_*` 会暴露到浏览器，不得放密钥。
- 外部链接、上传、富文本必须校验与净化。

## 4. API 与兼容

- UI 依赖 `@atproto/api`；后端 Lexicon 变更时确认版本或使用 `HACKING.md` 的 link 流程。
- `tools.ozone.*` 契约变更先在 atproto 完成并 codegen，再更新 UI。
- 不复制认证逻辑；统一使用 `lib/client.ts` 与现有 hooks。
- 修改 OAuth 客户端配置前确认部署域名与回调地址。

## 5. 测试

```bash
corepack yarn test
corepack yarn type-check
corepack yarn lint
```

- 权限改动覆盖 admin / moderator / triage / verifier。
- Cypress 仅在重大功能时新增；优先补 Vitest 单元测试。
- 后端行为测试放 atproto `packages/ozone`，通过 API 断言。
- 涉及构建配置时运行 `corepack yarn build`。

## 6. 上游保持

- 不覆盖或重写上游 `AGENTS.md`；本文件是唯一叠加位置。
- 不批量格式化、不重命名 `app/` 路由、不升级无关依赖。
- 同步上游后重跑：`node scripts/apply-repo-overlays.mjs`、`npm run verify`、`npm run codegraph:sync`。
- 本地开发分支保持提交主题单一，便于 rebase。
