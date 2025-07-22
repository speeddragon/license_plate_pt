defmodule LicensePlatePT.TestUtils do
  @moduledoc """
    Test utils for license plate
  """

  import ExUnit.Assertions, only: [assert: 1]
  import LicensePlatePT.Information, only: [get_type: 1]

  def assert_license_plate_type([], _),
    do: raise("Expected a list of license plates, got an empty list")

  def assert_license_plate_type(license_plate, plate_type) when is_binary(license_plate) do
    assert_license_plate_type([license_plate], plate_type)
  end

  def assert_license_plate_type(license_plate, plate_type) when is_integer(plate_type) do
    assert_license_plate_type(license_plate, [plate_type])
  end

  def assert_license_plate_type(license_plates, plate_types)
      when is_list(license_plates) and is_list(plate_types) do
    Enum.each(license_plates, fn license_plate ->
      [plate_type] = get_type(license_plate)

      assert plate_type in plate_types
    end)
  end
end
