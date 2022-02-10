defmodule Prim.Primes.BatchWorker do
  @moduledoc """
  Calculate all prime numbers for a given batch (from -> to).

  For prime number the process answers with the given answer-function.
  If the batch is completed, the given on-finished-function will be exectued.
  The process is stopped when finished.
  """

  alias Prim.Primes.BatchWorker

  use GenServer

  @type t() :: %BatchWorker{
          batch_from: pos_integer(),
          batch_to: pos_integer(),
          tester_module: module(),
          answer_function: (pos_integer() -> :ok),
          on_finished_function: (() -> :ok)
        }
  @enforce_keys [
    :batch_from,
    :batch_to,
    :tester_module,
    :answer_function,
    :on_finished_function
  ]
  defstruct [
    :batch_from,
    :batch_to,
    :tester_module,
    :answer_function,
    :on_finished_function
  ]

  @doc """
  Creates a `Prim.Primes.BatchWorker.t()`-stuct for a given batch size (from & to).

  You musst also specify a tester_module implementing `Prim.PrimeTester` behaviour.
  """
  @spec build_with_defaults(pos_integer(), pos_integer(), module(), atom()) :: t()
  def build_with_defaults(from, to, tester_module, process \\ {:global, Prim.Primes}) do
    %BatchWorker{
      batch_from: from,
      batch_to: to,
      tester_module: tester_module,
      answer_function: fn n -> GenServer.cast(process, {:new_prime, n}) end,
      on_finished_function: fn -> GenServer.cast(process, {:batch_finished, Node.self()}) end
    }
  end

  def start_link(%BatchWorker{} = state) do
    GenServer.start_link(__MODULE__, state)
  end

  @impl true
  def init(state) do
    Process.send_after(self(), {:check, state.batch_from}, 1)

    {:ok, state}
  end

  @impl true
  def handle_info({:check, n}, %BatchWorker{} = state) do
    if state.tester_module.prime?(n) do
      state.answer_function.(n)
    else
      state
    end

    if n + 1 <= state.batch_to do
      send(self(), {:check, n + 1})
      {:noreply, state}
    else
      state.on_finished_function.()
      {:stop, :normal, state}
    end
  end
end
