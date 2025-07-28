defmodule LicensePlatePT.Validation do
  @moduledoc """
  Validation and checks to perform on a license plate.
  """

  alias LicensePlatePT.LicensePlate

  import LicensePlatePT, only: [to_struct!: 1]

  @type123_max_number LicensePlatePT.get_type123_max_number()
  @type4_max_number LicensePlatePT.get_type4_max_number()

  @doc """
  Check if a license plate is valid.
  This support both types of license plate, with and without dashes.

  ## Options
  * `dashed` Force license plate verification to have "-". Defaults to `false`.
  * `stripped` Force license plate verification to not have "-". Defaults to `false`.
  """
  def valid?(license_plate, opts \\ [])

  def valid?(nil, _opts), do: false

  def valid?(license_plate, opts) when is_binary(license_plate) do
    # Because we use a regex without start and end forced, we need to force prior.
    license_plate
    |> case do
      <<_::binary-size(2)>> <> "-" <> <<_::binary-size(2)>> <> "-" <> <<_::binary-size(2)>> ->
        license_plate

      <<_::binary-size(6)>> ->
        license_plate

      _ ->
        :error
    end
    |> check_license_plate_dashed_or_stripped(opts)
    |> case do
      :error ->
        false

      license_plate ->
        undashed_license_plate = String.replace(license_plate, "-", "")

        # Match the
        LicensePlatePT.license_plate_without_hiffen_regex()
        |> Regex.run(String.upcase(undashed_license_plate))
        |> is_nil()
        |> Kernel.!()
    end
  end

  def valid?(%LicensePlate{type: 4, letters: "AAAA", numbers: 0}, _), do: false

  def valid?(
        %LicensePlate{type: type, letters: letters, numbers: numbers},
        _opts
      )
      when type in [1, 2, 3] and
             (byte_size(letters) != 2 or numbers <= 0 or numbers > @type123_max_number),
      do: false

  def valid?(
        %LicensePlate{type: type, letters: letters, numbers: numbers},
        _opts
      )
      when type == 4 and (byte_size(letters) != 4 or numbers < 0 or numbers > @type4_max_number),
      do: false

  def valid?(
        %LicensePlate{type: type, letters: _, numbers: _} = license_plate,
        _opts
      )
      when type in [1, 2, 3, 4] do
    license_plate
    |> to_string()
    |> valid?()
  end

  def valid?(_, _), do: false

  @doc """
  Check if a license plate pattern is valid.
  """
  def valid_partial?(license_plate, opts \\ [])
  def valid_partial?(nil, _), do: false

  def valid_partial?(partial_license_plate, opts) do
    partial_license_plate
    |> String.replace("?", "_")
    |> String.replace("*", "_")
    |> check_license_plate_dashed_or_stripped(opts)
    |> case do
      :error ->
        false

      license_plate ->
        undashed_license_plate = String.replace(license_plate, "-", "")

        # Match the
        LicensePlatePT.license_plate_partial_without_hiffen_regex()
        |> Regex.run(String.upcase(undashed_license_plate))
        |> is_nil()
        |> Kernel.!()
    end
  end

  @type option() :: {:dashed, boolean()} | {:stripped, boolean()}

  @spec check_license_plate_dashed_or_stripped(String.t() | :error, [option]) ::
          String.t() | :error
  defp check_license_plate_dashed_or_stripped(:error, _), do: :error

  defp check_license_plate_dashed_or_stripped(license_plate, opts)
       when is_binary(license_plate) do
    dashed = Keyword.get(opts, :dashed, false)
    stripped = Keyword.get(opts, :stripped, false)

    cond do
      dashed and stripped ->
        raise ArgumentError, message: "Only `:dashed` or `:stripped` can be enable at one time."

      check_license_plate_dashed(dashed, license_plate) ->
        license_plate

      check_license_plate_stripped(stripped, license_plate) ->
        license_plate

      dashed == false and stripped == false ->
        license_plate

      true ->
        :error
    end
  end

  defp check_license_plate_dashed(true, license_plate), do: valid_dash_structure?(license_plate)
  defp check_license_plate_dashed(false, _), do: false
  defp check_license_plate_stripped(true, license_plate), do: String.length(license_plate) == 6
  defp check_license_plate_stripped(false, _), do: false

  @spec valid_dash_structure?(binary()) :: boolean()
  defp valid_dash_structure?(license_plate) do
    parts = String.split(license_plate, "-")

    if length(parts) == 3 do
      String.length(Enum.at(parts, 0)) == 2 && String.length(Enum.at(parts, 1)) == 2 &&
        String.length(Enum.at(parts, 2)) == 2
    else
      false
    end
  end

  @doc """
  Check if a license plate is ordered before than another license plate.
  """
  @spec before_then!(String.t(), String.t()) :: boolean() | no_return()
  def before_then!(license_plate, license_plate), do: false

  def before_then!(license_plate1, license_plate2)
      when is_binary(license_plate1) and is_binary(license_plate2) do
    %LicensePlate{type: type1, letters: letters1, numbers: numbers1} = to_struct!(license_plate1)
    %LicensePlate{type: type2, letters: letters2, numbers: numbers2} = to_struct!(license_plate2)

    if type1 == type2 do
      # Check by Letter
      if letters1 == letters2 do
        # Check by Number
        numbers1 < numbers2
      else
        letters1 < letters2
      end
    else
      type1 < type2
    end
  end

  def before_then!(_, _), do: false

  @doc """
  Check if a license plate is ordered after then another license plate.
  """
  @spec after_then!(String.t(), String.t()) :: boolean() | no_return()
  def after_then!(license_plate, license_plate), do: false

  def after_then!(license_plate1, license_plate2)
      when is_binary(license_plate1) and is_binary(license_plate2),
      do: !before_then!(license_plate1, license_plate2)

  def after_then!(_, _), do: false
end
