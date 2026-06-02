# 技能验证流程（Skill Verification）

本目录记录如何对 `plugins/agent-docs/skills/` 和 `plugins/code-quality/skills/` 下的每个技能执行
RED → GREEN → REFACTOR 测试循环。流程严格遵循 `superpowers:writing-skills`
铁律：**没有失败测试，不写技能**。

适用场景：
- 新增技能前的基线测量
- 修改已有技能时的回归验证
- 把 `quality-reviewer` / `diff-cleanup` 等技能迁移到本仓库时的合规验证

## 当前状态

| 技能 | RED 基线 | GREEN 验证 | 备注 |
|---|---|---|---|
| `bootstrap-agent-docs` | — | — | 既有，本流程引入前的技能 |
| `clean-commit` | — | — | 既有；委托给 `quality-reviewer` |
| `diff-cleanup` | ✅ 已记录 | ✅ 通过（场景 B） | 三条规则全部由子代理字面执行，verbatim 援引规则编号 |
| `learn` | — | — | 既有 |
| `quality-reviewer` | ✅ 已记录 | ✅ 通过（场景 A、C） | A 测试 pre-commit 评审流；C 在四重压力下未退化 |
| `remember` | — | — | 既有 |

> GREEN 测试使用 fallback 模式（子代理直接 Read `~/.agents/skills/<name>/SKILL.md`
> 而不是通过 `skill` 工具），原因见下方"关键时序约束"。

## 核心概念

| 阶段 | 含义 | 产出 |
|---|---|---|
| **RED** | 不加载技能，让子代理处理目标场景，观察其自然失败 | 失败行为清单 + 子代理使用过的合理化借口（verbatim） |
| **GREEN** | 写入最简技能仅修复 RED 阶段观察到的失败，再次运行同一场景验证合规 | 通过合规检查的子代理报告 |
| **REFACTOR** | 找出 GREEN 阶段子代理用过的新合理化借口，堵漏后再次验证 | bulletproof 的技能版本 |

## 技能发现：symlink 而非 PATH

OpenCode 子代理只发现以下两个位置的技能：

- `~/.config/opencode/skill/`（个人 superpowers 套件）
- `~/.agents/skills/`（用户级别技能仓库）

本仓库的技能位于 `plugins/agent-docs/skills/<name>/` 和 `plugins/code-quality/skills/<name>/`（Claude Code plugin
布局）。为了让 OpenCode 子代理能发现它们，**测试前必须建立 symlink**：

```bash
make test-skills-link
```

该命令会为两个 plugin 的 skills/ 下的每个技能在
`~/.agents/skills/<name>` 创建符号链接。源始终是这个 repo 中的技能目录，所以
你对 `SKILL.md` 的任何编辑都会被立刻测试到。

测试完毕后用 `make test-skills-unlink` 移除 symlink，避免污染主目录。

### 关键时序约束：派发前完成 symlink

OpenCode 的 skills registry 在**会话启动时**扫描 `~/.agents/skills/`，结果
缓存到本次会话的进程内存。新建的 symlink **不会**在运行中的会话里出现，
即使父代理派出新的 Task 子代理也不行——子代理的 `<available_skills>` 列表
继承自父代理，从同一缓存读取。

实证验证过：`make test-skills-link` 之后立刻派发子代理，子代理报告
`quality-reviewer: no, diff-cleanup: no`。这不是 symlink 创建失败
（`test-skills-status` 显示 `OK`），而是 registry 不再扫描。

工作流必须是：

```text
1. make test-skills-link       # 先建立 symlink
2. 退出当前 opencode 会话
3. 新开 opencode               # 启动时重新扫描 ~/.agents/skills/
4. Task 派发 GREEN 子代理      # 此时新技能才出现在 <available_skills>
```

实战中验证过的 fallback：当 `skill` 工具说 "not found" 时，子代理可以**直接
读 SKILL.md 文件**（用 Read 工具）然后字面执行其规则。这种 fallback 在
场景 B（diff-cleanup）的 GREEN 测试中产生了完全合规的结果。要触发这个
fallback，必须在子代理 prompt 中显式提示：

> If the `skill` tool returns "not found", read `~/.agents/skills/<name>/SKILL.md`
> directly via the Read tool and follow its rules literally.

否则子代理会退化成 ad-hoc review。fallback **不能替代**正式注册——它只是
开发期省去 opencode 重启的便利路径。

## 场景目录约定

每个场景是一个**临时 git 仓库**，构造脚本生成在
`${TMPDIR}/opencode/skill-tests/<skill-name>-<scenario-letter>/`。约定如下：

| 场景类型 | base 设置 | working tree 状态 |
|---|---|---|
| **pre-commit 评审** | `main` 分支，单一 initial commit | 工作区有未提交 diff |
| **branch cleanup** | `main` + 远端 `origin/main` ref | 切换到 feature 分支，diff 已提交 |
| **pressure 场景** | 与 pre-commit 相同 | 工作区有 diff，提示包含紧迫语 |

仓库需要包含：
- 真实的 `go.mod` / `package.json` / `pyproject.toml` / `Cargo.toml` 之一，使
  工具链探测真正生效
- `AGENTS.md`（可选）声明 lint/test 命令，验证技能是否会优先读取
- 真正能跑通的代码——空 stub 会让"运行 lint"这步退化成噪音

构造脚本统一放在 `docs/verify/scenarios/<skill-name>/build-<letter>.sh`，
幂等可重复执行。每次 GREEN 测试前必须先运行对应脚本，把场景重置到干净的
未触碰状态——上一次子代理的修改会污染下一次测试。

当前已有的脚本：

```text
docs/verify/scenarios/
├── diff-cleanup/
│   └── build-b.sh          # AI slop 在 feature 分支上的 cleanup 场景
└── quality-reviewer/
    ├── build-a.sh          # 混合 Go+Python 的 pre-commit 评审
    └── build-c.sh          # 紧急 hotfix 压力场景
```

## 子代理调用：背景 + 结构化报告

每个场景**用一次后台 Task 调用**测试，三个场景**并行**触发。提示遵循统一模板：

```text
You are a coding assistant. The user just said: "<用户原话>"

Working directory: <场景目录绝对路径>

CONSTRAINTS:
- The `<skill-name>` skill is available via the skill tool. Load it FIRST.
- Read it carefully and FOLLOW its required behaviors literally.
- Do NOT ask clarifying questions before starting.

When done, return a STRUCTURED REPORT with these exact sections:

1. Did you load the skill? (yes/no + when in the flow)
2. <skill 的每条必行规则，逐条问是否执行>
3. Final report you gave the user (paste verbatim)
4. Verbatim rationalizations (phrases used to justify skipping or simplifying)
```

子代理回答中**最有价值的部分是 verbatim rationalizations**——它们暴露漏洞，
直接喂回 REFACTOR 阶段。

RED 阶段使用同一模板，仅把 CONSTRAINTS 改为：

```text
- Do NOT load any skills via the skill tool. Do not invoke `skill` at all.
```

## 合规判定标准

GREEN 阶段每条 SKILL.md 中"required"的行为都对应一个 yes/no 检查。例如
`quality-reviewer` 当前要求：

| 必行规则 | GREEN 通过条件 |
|---|---|
| 三路并行评审 | 子代理报告中能逐条列出 Simplify / Correctness / Efficiency 三个 pass 各自的发现 |
| grep 调用方 | 报告中给出 `git grep` 命令 + 检查过的符号 + 发现 |
| 验证 skip 借口 | 用户说"skip tests"时，子代理报告自己测了一遍真实耗时再决定 |
| 结构化报告 | 报告确实使用 Fixed / Flagged / Gates / Verdict 四个标题 |
| 无纯粹拒绝 | 任何 "no, don't commit" 都跟着具体的 <2 分钟下一步 |

通过 = 全部 yes；否则进入 REFACTOR。

## REFACTOR：把合理化变成规则

每个 GREEN 失败都会留下子代理的 verbatim 借口，逐条写入技能的 Never / 
Stop conditions / "Verify before honoring" 段落。每堵一个漏洞，重跑同场景，
直到子代理找不到新的合理化路径。

写入新规则时遵循 `writing-skills` 的 CSO 规则：
- 描述字段只写**触发条件**，不要总结工作流
- 技术细节放在 SKILL.md 正文，单文件控制在 500 行内
- 大段补充材料放进 `references/` 子目录，由 SKILL.md 一级引用

## 完整工作流示例

以 `diff-cleanup` 技能为例：

```bash
# 1. 链接技能到 OpenCode 可发现路径，并重启 opencode
make test-skills-link
# （新开 opencode 会话，让父代理 skills registry 刷新）

# 2. 构造场景（每次 GREEN 测试前重置）
bash docs/verify/scenarios/diff-cleanup/build-b.sh

# 3. RED：不加载技能，跑一次基线
#    （在 opencode 会话中通过 Task 调用，prompt 模板见上）

# 4. 写最简 SKILL.md，只针对 RED 阶段观察到的失败

# 5. GREEN：加载技能，跑同一场景
bash docs/verify/scenarios/diff-cleanup/build-b.sh   # 重置场景
#    （在 opencode 会话中通过 Task 调用，CONSTRAINTS 改为"必须加载"）

# 6. 如果发现新合理化，回到 REFACTOR；否则结束

# 7. 清理（开发完成、不再需要测试时）
make test-skills-unlink
```

`make test-skills-status` 在任何时候都可以查看哪些技能 symlink 当前
有效、过期或缺失。

## 何时跳过这个流程

只有以下情况可以跳过基线测试：
- 修改纯属拼写或格式调整，不影响子代理行为判断
- 修改的是技能描述（frontmatter），但**正文行为契约不变**

任何涉及 required behaviors / Never / Stop conditions / 报告格式的修改，
都必须重跑 GREEN。
