defmodule Prim.PrimeTester do
  @moduledoc """
  The behaviour `Prim.PrimeTester` needs to implement a
  `prime?/1` function.

  `Prim.PrimeTester.MillerRabin` is an example implementation.
  """

  @doc """
  Determine if a given `pos_integer()` is a prime number.

  Returns true or false.
  """
  @callback prime?(pos_integer()) :: boolean()
end
