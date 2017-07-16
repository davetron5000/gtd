# gtd - CLI for managing a basic GTD-like workflow

`gtd` is a basic CLI for managing a todo list that is compatible with [todo.txt](http://todotxt.com) and supports part of a [GTD](http://gettingthingsdone.com) workflow.  It's also compatible with [SwiftoDo](http://swiftodoapp.com) on iOS, meaning you can manage your tasks on your phone on the go, but using the command-line while at your computer.

`gtd` knows about your main todo list as well as projects.  Each project can have a backlog of tasks, as well as metadata like
links, documents, and notes.  All of this is stored as plaintext.

## Install

```
gem install gtd
```

## Use Cases

### Create a todo list

```
> gtd init
```

### Interact with a todo list

```
> gtd ls                     # lists tasks in main todo list
> gtd done «task id»         # complete a task
> gtd vi                     # edit the todo list file directly
> gtd new This is a new task # create a new task
> gtd new -p 2               # Add the next action from project # 2 to the todo list
```

### Projects

```
> gtd p                      # list all projects
> gtd p -l                   # list all projects with their tasks
> gtd p tasks «project id»   # show project-specific tasks
> gtd p archive «project id» # archive a project (e.g. mark it done)
> gtd p audit                # show projects with next actions that aren't on your TODO list
```

