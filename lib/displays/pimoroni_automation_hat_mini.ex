defmodule St7735.Displays.PimoroniAutomationHatMini do
  alias St7735.DisplayBehaviour

  use Bitwise

  @behaviour DisplayBehaviour

  ######################################################################################################################
  @impl DisplayBehaviour
  @doc """
  draw/2.

  """
  @spec img_data(St7735.t(), [float()]) :: DisplayBehaviour.img_data()
  def img_data(st7735, readings \\ [0.0, 12.123, 24.0]) do
    {:ok, background_img_mat} = Evision.imread(st7735.img_filepath)

    # starting_index used to adjust the offset of the readings
    starting_index = 1

    Enum.map_reduce(readings, {starting_index, background_img_mat}, fn reading, {index, acc} ->
      offset = st7735.offset * index

      {:ok, mat_with_reading} =
        Evision.putText(
          acc,
          :erlang.float_to_binary(reading, decimals: 3),
          [st7735.text_x, st7735.text_y + offset],
          Evision.cv_FONT_HERSHEY_TRIPLEX(),
          0.425,
          st7735.colour
        )

      width =
        (st7735.bar_width * (reading / 24.0))
        |> Kernel.trunc()

      {:ok, mat_with_bar_and_reading} =
        Evision.rectangle(
          mat_with_reading,
          # TODO, better way to decrease offset here...
          [st7735.bar_x, st7735.bar_y + (offset - 14)],
          # TODO, better way to decrease offset here...
          [st7735.bar_x + width, st7735.bar_y + st7735.bar_height + (offset - 14)],
          # TODO, why isn't this filling the rectangle?
          st7735.colour,
          [Evision.cv_FILLED()]
        )

      {reading, {index + 1, mat_with_bar_and_reading}}
    end)
    |> then(fn {_, {_, img_mat_with_readings_and_bars}} ->
      Evision.rotate(img_mat_with_readings_and_bars, Evision.cv_ROTATE_90_CLOCKWISE())
    end)
    |> then(fn {:ok, rotated_img_mat} -> Evision.Mat.to_binary(rotated_img_mat) end)
    |> then(fn {:ok, rgb888_img_bin} ->
      CvtColor.cvt(rgb888_img_bin, String.to_atom("#{Atom.to_string(:rgb)}888"), :rgb565)
    end)
    |> :binary.bin_to_list()
  end
end
