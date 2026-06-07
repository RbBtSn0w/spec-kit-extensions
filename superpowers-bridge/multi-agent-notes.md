

背景：
现在superpowers引入了一个新的特点，也就是subagent-driven-development。大体内容是：
1. 在根据spec执行writing-plans。第一步我们把一个足够大的需求写成了Spec，接下来的Plans需要将其拆分成足够小的Tasks。这些Tasks是sub-projects，有明确的边界。每一步是2-5分钟的原子动作（写一个失败的测试用例/跑一遍确认失败/写一个最小实现/跑测试确认通过用例检查/提交代码），贯彻DRY/YAGNI/TDD/频繁Commit等原则，同时禁止TODO/add appropriate error handling/similar to Task N等常见AI偷懒行为。并且最终Plan写完了需要self-review，确认Spec覆盖度/占位符扫描/一致性检查等等
2. 有了Plans之后接着executing-plans，默认是保底的一个Session从头跑到尾（如果当前环境不支持Subagents），但是Claude Code/Codex Cli都支持Subagents，所以通常我们会选择subagent-driven-development。在执行的过程中，先读Plans，然后Review，然后开始执行，如果有卡住的时候就停下来问，不让AI自己猜。
3. 给每一个Task都创建一个新的Subagent，每个Subagent会有两个阶段的Review保证输出。这个Skill里还带有implementer-prompt.md spec-reviewer-prompt.md和code-quality-reviewer-prompt.md三个prompt，分别用于执行和Review。因为每个Subagent都只用自己的context所以不会撑爆主Session context，并且他们按照TDD实现，有一些任务甚至可以并行执行。同时Skill里还写了一堆Red Flags，不让AI跑偏，比如不要未经允许就在main/master开始写代码（正常一个大需求会开一个worktree来写，有另一个skill，不做赘述）；不要还没修完issues就跳过开始执行下一步；不要让Subagent去读Plan file，Subagent只需要被告知足够的context的就行，读Plan file是主Session的工作，等等等等，非常harness。

这里Subagent不继承主Session的context，使得每个Subagent可以独立不受污染。同时明令禁止AI在执行任务时停下来问要不要继续，重点。

现在的superb在做bridge的时候缺少了这种能力，当初spec的plan 和 task，是否能对接上 subagent-driven-development （当前是单agent工作方式），两种模式下的完整能力，是缺少的，所以需要补齐和完善。

目前的bridge模式是基于spec kit + 单agent，现在需要重构，使得他能够支持subagent-driven-development。

开始前，需要了解下speckit的工作流程方式，以及superpowers的工作方式。 才能将两者的边界和融合做的最佳化。

改造的前提是不要过多造轮子，在利用superpowers的skill处理的时候，不要破坏speckit的工作目录产物的结构，可以增加但是不要破坏兼容性。

整个spec文档过程都用中文进行。








【当前模式：计划】

非常感谢您的提醒！您说得完全正确，刚才的设计确实有些偏离了 `superpowers` 原生的设计本意，将其“过度复杂化”了。

我们来重新对齐并澄清 **Superpowers 原生的 Subagent 使用规范与设计定义**：

### 1. 纠偏：Superpowers 是如何定义与使用 Subagent 的？
在 Superpowers 中，**`tasks.md`（或 Plan 方案）本身是纯扁平且白盒的，并不需要在静态设计期去划分 `## Subagent-1` 这样的物理区块。**
*   **静态 Plan 工件**：Plan 只是非常单纯、扁平的 Task 1、Task 2。只是在文档头部，会有一行强约束声明：
    `> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended)...`
*   **动态 Runtime 纪律**：SDD 是一个 **“运行时（Runtime）”的执行纪律**。当 Controller（主 Agent）读取并准备执行这个 Plan 时，它发现需要使用 `subagent-driven-development`。
*   **自发派生（Auto-Dispatching）**：主 Agent 作为 Controller，在内存中自发地开始循环。对于每一个 Task，它调用系统底层的 Task 调度工具（如 `TaskCreate`，在我们的环境里则是原生工具 `define_subagent` 与 `invoke_subagent`），派生出一个干净、隔离的子会话去执行。
*   **增量发现（Accumulated Discoveries）**：主 Agent 动态收集子会话退出的 discoveries 并将其“前置（prepend）”到下一个 Task 子会话的 Prompt 里，这也是在运行时内存中完成的。

---

## 重新梳理：在 Spec Kit 扩展中“拒绝造轮子”的极简接入细节

既然 SDD 是一套运行时纪律，那么我们的 `superpowers-bridge` 甚至**不需要去改写 `tasks.md` 的格式**。我们只需要在 Spec Kit 原生的流程里，扮演**“规约注入者”**和**“状态同步者”**即可。

整个流程的实现细节，重新梳理如下：

### 1. Plan 与 Tasks 阶段（/speckit.plan & /speckit.tasks）
*   **原生的 Spec Kit 流程**：
    保持不变。`/speckit.plan` 生成 `plan.md`，`/speckit.tasks` 生成 `tasks.md`。
*   **Bridge 的唯一微调**：
    当 `/speckit.tasks` 生成 `tasks.md` 后，或者在 `after_tasks` 的 Hook 中：
    我们确保 `tasks.md` 的头部带上 Superpowers 的**执行指引声明**：
    > `> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) to implement this plan task-by-task.`

---

### 2. Implement 阶段（/speckit.implement）—— SDD 的真正执行点
当用户执行 `/speckit.implement` 时，Spec Kit 会触发 `before_implement` 的 Hook（绑定 [commands/controller.md](file:///Users/snow/Documents/GitHub/spec-kit-extensions/superpowers-bridge/commands/controller.md)，我们可以将它重构或并入 sdd 逻辑）：

*   **Bridge Command 的指令内容 (引导主 Agent 扮演 Controller)**：
    当 [commands/controller.md](file:///Users/snow/Documents/GitHub/spec-kit-extensions/superpowers-bridge/commands/controller.md) 启动时，它在指令中写道：
    > 1. Look for `subagent-driven-development/SKILL.md` and `test-driven-development/SKILL.md` in workspace or global paths.
    > 2. Read the contents of both SKILL files.
    > 3. Acting as the Controller specified in `subagent-driven-development/SKILL.md`:
    >    - Read the tasks declared in the active `tasks.md`.
    >    - For each task:
    >      a. Call `define_subagent` to spawn an isolated general-purpose worker.
    >      b. Inject the task-specific files scope and TDD checklist.
    >      c. Prepend the current "Accumulated Discoveries" (if any) to the worker's prompt.
    >      d. Run the subagent (setting Workspace to `share`).
    >      e. Review the returned diff via spec compliance and code quality reviews.
    >      f. Collect discoveries and update the global discoveries list.
    >    - Do NOT ask the user for confirmation between tasks. Continuous execution.

*   **Subagent Worker 在运行时的状态**：
    它由 Controller 动态派生，它的 system prompt 里包含了 TDD 规约和局部 Task 任务。它在一个干净的沙盒里，只对分配给它的文件进行红绿重构，完成后退出。

---

### 3. Verify 阶段（/speckit.implement 执行完毕后）
当所有 Subagent 跑完任务后，主 Session 触发 `after_implement` Hook（绑定 [commands/verify.md](file:///Users/snow/Documents/GitHub/spec-kit-extensions/superpowers-bridge/commands/verify.md)）：
*   主 Agent 读取本地已安装的 `verification-before-completion/SKILL.md` 并执行。
*   跑全量集成测试，生成 evidence 存证，并将 `spec.md` 中的 status 标记为 `Verified`。

---

## 这样设计的核心优势

1.  **真正的“不造轮子”**：
    `superpowers-bridge` 的扩展代码保持 100% 的纯 Markdown。所有的 SDD 智能体调度算法、自检算法都直接从本地的 `subagent-driven-development/SKILL.md` 中实时读取。
2.  **不破坏 Spec Kit 原生文件格式**：
    `tasks.md` 依然保持 Spec Kit 原生生成的纯净 Markdown Task Checklist 格式，不掺杂任何复杂的 AI 元数据。它不仅对 Agent 友好，人类工程师阅读和勾选也完全无压力。
3.  **零重构风险**：
    由于是在 `before_implement` 的 Hook 中通过 Prompt 引导主 Agent 改变自己的执行策略，我们不需要编写任何 JS 调度器，从而杜绝了任何由于系统升级导致的 runtime crash。

这才是 Superpowers 最纯正的 SDD 设计逻辑。您觉得这个精简、忠于原生的梳理方案是否切中要害？