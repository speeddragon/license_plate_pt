defmodule LicensePlatePT.Information.Type1Test do
  @moduledoc false

  @subject LicensePlatePT.Information.Type1

  use ExUnit.Case, async: true

  doctest @subject

  alias LicensePlatePT.LicensePlate

  describe "get_year_by_letters" do
    assert @subject.get_year_by_letters("GJ") == [84]
  end
end
