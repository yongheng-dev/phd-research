# OpenCode 使用指南

当前项目已经收敛为单一 OpenCode 运行体系。

## 运行入口

```bash
cd /Users/xuyongheng/PhD-Research
opencode
```

## 当前命令

- `/find`
- `/read`
- `/think`
- `/write`
- `/review`
- `/plan`
- `/admin`

## 模型策略

- root: `github-copilot/claude-sonnet-4.6`
- heavy: `github-copilot/claude-opus-4.7`
- medium: `github-copilot/claude-sonnet-4.6`
- light: `github-copilot/claude-haiku-4.5`
- audit: `github-copilot/gpt-5.4`

## 当前原则

1. 不再保留旧初始化链
2. 不再保留旧 skill/reference 兼容层
3. 不再保留双轨 memory 体系
4. 领域知识统一从 `domains/ai-in-education/` 提供
