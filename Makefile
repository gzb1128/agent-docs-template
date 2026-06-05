# Makefile for skill-forge
#
# Skills in this repo live in plugins/<plugin-name>/skills/<name>/, following
# the Claude Code plugin directory layout.
# OpenCode subagents only discover skills from ~/.agents/skills/.
#
# To make this repo's skills discoverable by OpenCode subagents without
# copying files, we bridge them via symlinks to ~/.agents/skills/.
# See docs/verify/README.md for details.

PLUGIN_DIRS := $(wildcard $(CURDIR)/plugins/*)
SKILLS_SRC_DIRS := $(wildcard $(CURDIR)/plugins/*/skills)
SKILLS_DST := $(HOME)/.agents/skills

.PHONY: help validate test-skills-link test-skills-unlink test-skills-status

help:
	@echo "Targets:"
	@echo "  validate              run 'claude plugin validate' on marketplace + all plugins"
	@echo "  test-skills-link      symlink every skill into ~/.agents/skills/ (for GREEN tests)"
	@echo "  test-skills-unlink    remove those symlinks"
	@echo "  test-skills-status    show which symlinks currently exist"

validate:
	claude plugin validate .
	@for plugin in $(PLUGIN_DIRS); do \
		if [ -d "$$plugin/.claude-plugin" ]; then \
			claude plugin validate "$$plugin" || exit $$?; \
		fi; \
	done

# Create symlinks at ~/.agents/skills/<name> for each plugin's skills/<name>/.
# The source is always the repo directory, so SKILL.md edits are immediately testable.
#
# Important: opencode's parent session skills registry is built at startup.
# After creating new symlinks, you must restart opencode (or start a new session)
# before subagents can see the new skills in <available_skills>.
# See docs/verify/README.md "Critical Timing Constraint" section.
test-skills-link:
	@mkdir -p $(SKILLS_DST)
	@for src_dir in $(SKILLS_SRC_DIRS); do \
		for name in $$(ls "$$src_dir" 2>/dev/null); do \
			src="$$src_dir/$$name"; \
			dst="$(SKILLS_DST)/$$name"; \
			if [ -e "$$dst" ] && [ ! -L "$$dst" ]; then \
				echo "SKIP $$name: $$dst exists and is NOT a symlink (refusing to overwrite real content)"; \
				continue; \
			fi; \
			ln -sfn "$$src" "$$dst"; \
			echo "LINK $$name -> $$src"; \
		done; \
	done
	@echo ""
	@echo "Next: restart opencode (or start a fresh session) so the skill"
	@echo "registry picks up the new entries before dispatching test subagents."

test-skills-unlink:
	@for src_dir in $(SKILLS_SRC_DIRS); do \
		for name in $$(ls "$$src_dir" 2>/dev/null); do \
			dst="$(SKILLS_DST)/$$name"; \
			if [ -L "$$dst" ]; then \
				rm "$$dst" && echo "UNLINK $$name"; \
			fi; \
		done; \
	done

test-skills-status:
	@for src_dir in $(SKILLS_SRC_DIRS); do \
		for name in $$(ls "$$src_dir" 2>/dev/null); do \
			dst="$(SKILLS_DST)/$$name"; \
			if [ -L "$$dst" ]; then \
				target=$$(readlink "$$dst"); \
				if [ "$$target" = "$$src_dir/$$name" ]; then \
					echo "OK    $$name -> $$target"; \
				else \
					echo "STALE $$name -> $$target (expected $$src_dir/$$name)"; \
				fi; \
			elif [ -e "$$dst" ]; then \
				echo "REAL  $$name (not a symlink — manual install?)"; \
			else \
				echo "MISS  $$name (run 'make test-skills-link')"; \
			fi; \
		done; \
	done
