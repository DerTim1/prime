defmodule Prim.Primes do
  @moduledoc """
  Calculate all prime numbers and call UI-update-function for the highest new prime number.
  """
  require Logger

  alias Prim.Primes

  use GenServer

  @processes_per_worker 8

  @type t() :: %Primes{
          max_prime: pos_integer(),
          previous_primes: [pos_integer()],
          batch_size_fn: (pos_integer() -> pos_integer()),
          batch_amount: %{atom() => non_neg_integer()},
          batch_position: pos_integer(),
          tester_module: module(),
          answer_function: (pos_integer() -> :ok)
        }
  @enforce_keys [
    :max_prime,
    :previous_primes,
    :batch_size_fn,
    :batch_amount,
    :batch_position,
    :tester_module,
    :answer_function
  ]
  defstruct [
    :max_prime,
    :previous_primes,
    :batch_size_fn,
    :batch_amount,
    :batch_position,
    :tester_module,
    :answer_function
  ]

  def start_link(start) do
    GenServer.start_link(__MODULE__, start, name: {:global, Prim.Primes})
  end

  @impl true
  def init(start) do
    Process.send_after(self(), :start_sequence, 20_000)

    {:ok,
     %Primes{
       max_prime: start,
       previous_primes: [],
       batch_size_fn: fn _ -> 1000 end,
       batch_amount: %{},
       batch_position: 2,
       tester_module: Prim.PrimeTester.MillerRabin,
       answer_function: fn n ->
         Phoenix.PubSub.broadcast(Prim.PubSub, "new_prime", {:update, n})
       end
     }}
  end

  @impl true
  def handle_cast({:new_prime, n}, %Primes{} = state) do
    new_state =
      if n > state.max_prime do
        state.answer_function.(n)
        add_new_max_prime(state, n)
      else
        state
      end

    {:noreply, new_state}
  end

  def handle_cast({:batch_finished, node}, %Primes{} = state) do
    new_state = update_batch_amount_for(state, node, &(&1 + 1))

    send(self(), {:new_batch, node})

    {:noreply, new_state}
  end

  @impl true
  def handle_info(:start_sequence, %Primes{} = state) do
    new_state =
      Enum.reduce(Node.list(:connected), state, fn node, new_state ->
        if Map.has_key?(new_state.batch_amount, node) do
          # Node already processing batches
          new_state
        else
          for _ <- 1..@processes_per_worker do
            send(self(), {:new_batch, node})
          end

          update_batch_amount_for(new_state, node, @processes_per_worker)
        end
      end)

    Process.send_after(self(), :start_sequence, 30_000)

    {:noreply, new_state}
  end

  def handle_info({:new_batch, node}, %Primes{batch_amount: amounts} = state) do
    batch_amount = Map.get(amounts, node)

    if batch_amount && batch_amount > 0 do
      {from, to} = calculate_next_batch(state)
      Logger.info("Spawn for #{from} #{to}")

      Node.spawn_link(node, fn ->
        GenServer.start_link(
          Primes.BatchWorker,
          Primes.BatchWorker.build_with_defaults(from, to, state.tester_module)
        )
      end)

      updated_state = update_batch_amount_for(state, node, batch_amount - 1)
      {:noreply, %Primes{updated_state | batch_position: to + 1}}
    else
      {:noreply, state}
    end
  end

  @spec add_new_max_prime(t(), pos_integer()) :: t()
  defp add_new_max_prime(
         %Primes{previous_primes: previous_primes, max_prime: max_prime} = state,
         n
       ) do
    new_previous_primes = Enum.take([max_prime | previous_primes], 8)
    %Primes{state | max_prime: n, previous_primes: new_previous_primes}
  end

  @spec calculate_next_batch(t()) :: {pos_integer, pos_integer()}
  defp calculate_next_batch(%Primes{batch_position: batch_position, batch_size_fn: batch_size_fn}) do
    from = batch_position
    to = batch_position + batch_size_fn.(batch_position)

    {from, to}
  end

  @spec update_batch_amount_for(
          t(),
          atom(),
          non_neg_integer() | (non_neg_integer() -> non_neg_integer())
        ) :: t()
  defp update_batch_amount_for(state, node, func) when is_function(func) do
    %Primes{state | batch_amount: Map.update!(state.batch_amount, node, func)}
  end

  defp update_batch_amount_for(state, node, batch_amount) do
    %Primes{state | batch_amount: Map.put(state.batch_amount, node, batch_amount)}
  end
end
