# gtd - CLI for managing a basic GTD-like workflow

`gtd` is a basic CLI for managing a todo list that is compatible with todo.txt and supports part of a GTD workflow.

`gtd` knows about your main todo list as well as projects.  Each project can have a backlog of tasks, as well as metadata like
links, documents, and notes.  All of this is stored as plaintext.

## Install

```
gem install gtd
```

**TODO** make a setup step

## Use Cases

### Interact with a todo list

```
> gtd ls # lists tasks in main todo list
> gtd done «task id» # complete a task
> gtd vi # edit the todo list file directly
```

### Projects

```
> gtd p # list all projects
> gtd p show «project id» # show all project meta data
> gtd tasks «project id» # show project-specific tasks
> gtd archive «project id» # archive a project (e.g. mark it done)
```

### Project/Task Interaction

In an ideal case, you only have one next action per project, and that next action is on your main todo list.  `gtd` knows this
and when you complete a task, it will move the top task from that task's project to the todo list.

You can also forcibly move the next task for a project onto the todo list.

