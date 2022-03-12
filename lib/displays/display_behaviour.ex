defmodule St7735.DisplayBehaviour do
  @moduledoc """
  Behaviour for St7735.Display implementations.

  """

  @type img_data() :: [non_neg_integer()]

  @callback img_data(St7735.t(), any()) :: img_data()
end
