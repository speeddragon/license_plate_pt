defmodule LicensePlatePT.LicensePlate do
  @moduledoc """
  Structrure for portuguese license plate.
  """

  @type t() :: %__MODULE__{
          type: integer(),
          letters: binary(),
          numbers: integer(),
          dashes: boolean() | nil
        }

  defstruct [:type, :letters, :numbers, :dashes]

  defimpl String.Chars do
    def to_string(%LicensePlatePT.LicensePlate{
          type: type,
          letters: letters,
          numbers: numbers,
          dashes: dashes
        })
        when dashes in [nil, false] do
      {numbers1, numbers2} = split_numbers(numbers)

      case type do
        1 ->
          "#{letters}#{numbers1}#{numbers2}"

        2 ->
          "#{numbers1}#{numbers2}#{letters}"

        3 ->
          "#{numbers1}#{letters}#{numbers2}"

        4 ->
          # Split letters
          <<letters1::binary-size(2), letters2::binary-size(2)>> = letters
          "#{letters1}#{numbers2}#{letters2}"
      end
    end

    def to_string(%LicensePlatePT.LicensePlate{
          type: type,
          letters: letters,
          numbers: numbers,
          dashes: true
        }) do
      {numbers1, numbers2} = split_numbers(numbers)

      case type do
        1 ->
          "#{letters}-#{numbers1}-#{numbers2}"

        2 ->
          "#{numbers1}-#{numbers2}-#{letters}"

        3 ->
          "#{numbers1}-#{letters}-#{numbers2}"

        4 ->
          # Split letters
          <<letters1::binary-size(2), letters2::binary-size(2)>> = letters
          "#{letters1}-#{numbers2}-#{letters2}"
      end
    end

    @spec split_numbers(integer()) :: {<<_::_*16>>, <<_::_*16>>}
    defp split_numbers(numbers) when is_integer(numbers) do
      numbers_string =
        numbers
        |> Integer.to_string()
        |> String.pad_leading(4, "0")

      <<numbers1::binary-size(2), numbers2::binary-size(2)>> = numbers_string

      {numbers1, numbers2}
    end
  end
end
