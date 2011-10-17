calculation {

  name "Electricity"
  label :electricity
  path "/business/energy/electricity/grid"

  drill {
    name "Country"
    label :country
    path "country"
    value "Argentina"
    fixed "Argentina"
    interface :drop_down
  }

  profile {
    name "Electricity Used"
    label :usage
    path "energyPerTime"
    interface :text_box
  }

  output {
    name "Carbon Dioxide"
    label :co2
    path "default"
  }

}

