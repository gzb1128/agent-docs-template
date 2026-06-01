# Makefile for agent-docs-template
#
# 本仓库的技能位于 plugins/agent-docs-tools/skills/<name>/，遵循 Claude Code
# 的 plugin 目录布局。但 OpenCode 子代理只从 ~/.agents/skills/ 发现技能。
#
# 为了在不复制文件的前提下让本仓库的技能被 OpenCode 子代理发现并测试，
# 用 symlink 把它们桥接到 ~/.agents/skills/。详见 docs/verify/README.md。

SKILLS_SRC := $(CURDIR)/plugins/agent-docs-tools/skills
SKILLS_DST := $(HOME)/.agents/skills

SKILL_NAMES := $(notdir $(wildcard $(SKILLS_SRC)/*))

.PHONY: help validate test-skills-link test-skills-unlink test-skills-status

help:
	@echo "Targets:"
	@echo "  validate              run 'claude plugin validate' on marketplace + plugin"
	@echo "  test-skills-link      symlink every skill into ~/.agents/skills/ (for GREEN tests)"
	@echo "  test-skills-unlink    remove those symlinks"
	@echo "  test-skills-status    show which symlinks currently exist"

validate:
	claude plugin validate .
	claude plugin validate ./plugins/agent-docs-tools

# 为每个 plugins/agent-docs-tools/skills/<name>/ 在 ~/.agents/skills/<name>
# 建立 symlink。源是 repo 中的目录，所以 SKILL.md 改动会立刻被测试到。
#
# 重要：opencode 父对话的 skills registry 在启动时构建。新建 symlink 后
# 必须重启 opencode（或开新会话），子代理才能在 <available_skills> 中
# 看到新加入的技能。详见 docs/verify/README.md 的"派发前完成 symlink"段落。
test-skills-link:
	@mkdir -p $(SKILLS_DST)
	@for name in $(SKILL_NAMES); do \
		src="$(SKILLS_SRC)/$$name"; \
		dst="$(SKILLS_DST)/$$name"; \
		if [ -e "$$dst" ] && [ ! -L "$$dst" ]; then \
			echo "SKIP $$name: $$dst exists and is NOT a symlink (refusing to overwrite real content)"; \
			continue; \
		fi; \
		ln -sfn "$$src" "$$dst"; \
		echo "LINK $$name -> $$src"; \
	done
	@echo ""
	@echo "Next: restart opencode (or start a fresh session) so the skill"
	@echo "registry picks up the new entries before dispatching test subagents."

test-skills-unlink:
	@for name in $(SKILL_NAMES); do \
		dst="$(SKILLS_DST)/$$name"; \
		if [ -L "$$dst" ]; then \
			rm "$$dst" && echo "UNLINK $$name"; \
		fi; \
	done

test-skills-status:
	@for name in $(SKILL_NAMES); do \
		dst="$(SKILLS_DST)/$$name"; \
		if [ -L "$$dst" ]; then \
			target=$$(readlink "$$dst"); \
			expected="$(SKILLS_SRC)/$$name"; \
			if [ "$$target" = "$$expected" ]; then \
				echo "OK    $$name -> $$target"; \
			else \
				echo "STALE $$name -> $$target (expected $$expected)"; \
			fi; \
		elif [ -e "$$dst" ]; then \
			echo "REAL  $$name (not a symlink — manual install?)"; \
		else \
			echo "MISS  $$name (run 'make test-skills-link')"; \
		fi; \
	done
