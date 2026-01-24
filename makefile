.PHONY: setup server console test lint db-reset

test:
	OS_ACTIVITY_MODE=disable \
	OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES \
	rails test