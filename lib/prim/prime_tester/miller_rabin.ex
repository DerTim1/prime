defmodule Prim.PrimeTester.MillerRabin do
  @moduledoc """
  Implements the [Miller–Rabin primality test](https://en.wikipedia.org/wiki/Miller%E2%80%93Rabin_primality_test).

  The implementation is quick (FIXME) and deterministic for numbers up to 3 317 044 064 679 887 385 961 981.
  FIXME A deterministic implementation for numbers above this limit needs to be implemented (slow).
  """

  require Integer

  @behaviour Prim.PrimeTester

  @doc """
  Tests if the given positive integer is a prime number, using the Miller-Rabin primality test.

  The implementation is deterministic for inputs up to 3 317 044 064 679 887 385 961 981 (~ 3.3*10^24).

  ## Examples

      iex> Prim.PrimeTester.MillerRabin.prime?(2)
      true
      iex> Prim.PrimeTester.MillerRabin.prime?(37)
      true
      iex> Prim.PrimeTester.MillerRabin.prime?(12409)
      true
      iex> Prim.PrimeTester.MillerRabin.prime?(99497)
      true
      iex> Prim.PrimeTester.MillerRabin.prime?(1)
      false
      iex> Prim.PrimeTester.MillerRabin.prime?(39)
      false
      iex> Prim.PrimeTester.MillerRabin.prime?(99503)
      false

  """
  @impl Prim.PrimeTester
  def prime?(1), do: false
  def prime?(2), do: true
  def prime?(n) when Integer.is_even(n), do: false

  def prime?(n) do
    {d, j} = calculate_greatest_j(n)

    test_for_candidates?(n, candidates(n), d, j)
  end

  # Find d (odd) and j with: n - 1 = d * 2^j
  @spec calculate_greatest_j(pos_integer) :: {pos_integer(), pos_integer()}
  defp calculate_greatest_j(n) do
    calculate_greatest_j_helper(n - 1, 0)
  end

  # Find d (odd) and j with: m = d * 2^j
  defp calculate_greatest_j_helper(d, j) when Integer.is_even(d) do
    calculate_greatest_j_helper(Integer.floor_div(d, 2), j + 1)
  end

  defp calculate_greatest_j_helper(d, j) do
    {d, j}
  end

  @spec candidates(pos_integer()) :: [pos_integer()]
  defp candidates(n) when n <= 41 do
    [2]
  end

  defp candidates(_n) do
    [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41]
  end

  @spec test_for_candidates?(pos_integer(), [pos_integer()], pos_integer(), pos_integer()) ::
          boolean()
  defp test_for_candidates?(n, candidates, d, j) do
    Enum.all?(candidates, &test_for_candidate?(n, &1, d, j))
  end

  @spec test_for_candidate?(pos_integer(), pos_integer(), pos_integer(), pos_integer()) ::
          boolean()
  defp test_for_candidate?(n, a, d, j) do
    # IO.inspect("Testing n=#{n} with a=#{a}")

    a_d_pow = Integer.pow(a, d)
    # a^d mod n == 1
    # a^(d*2^r) mod n == n - 1 for one 0 <= r < j
    test_1?(n, a_d_pow) or test_2?(n, a_d_pow, j, 0)
  end

  @spec test_1?(pos_integer(), pos_integer()) :: boolean()
  defp test_1?(n, a_d_pow),
    do: Integer.mod(a_d_pow, n) == 1

  @spec test_2?(pos_integer(), pos_integer(), pos_integer(), non_neg_integer()) :: boolean()
  defp test_2?(n, a_d_pow, j, r) when r < j,
    do:
      Integer.mod(a_d_pow, n) == n - 1 or
        test_2?(n, a_d_pow * a_d_pow, j, r + 1)

  defp test_2?(_n, _a_d_pow, _j, _r),
    do: false
end
