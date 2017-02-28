defmodule Todo.Server do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
  end

  def add(pid, entry) do
    GenServer.cast(pid, {:add, entry})
  end

  def update(pid, entry_id, updater_fun) do
    GenServer.cast(pid, {:update, entry_id, updater_fun})
  end

  def delete(pid, entry_id) do
    GenServer.cast(pid, {:delete, entry_id})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def init(name) do
    IO.puts "Starting todo server for #{name}"
    send(self(), {:long_init, name})
    {:ok, nil}
  end

  def handle_cast({:add, entry}, {name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_cast({:update, entry_id, updater_fun}, {name, todo_list}) do
    new_state = Todo.List.update_entry(todo_list, entry_id, updater_fun)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_cast({:delete, entry_id}, {name, todo_list}) do
    new_state = Todo.List.delete_entry(todo_list, entry_id)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_call({:entries, date}, _, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {name, todo_list}}
  end

  def handle_info({:long_init, name}, _) do
    {:noreply, {name, Todo.Database.get(name) || Todo.List.new}}
  end
end
