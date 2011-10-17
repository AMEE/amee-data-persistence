calculation {
   name 'Electricity'
   label :electricity
   path '/business/energy/electricity/grid'
   drill {
     label :country
     path 'country'
     fixed 'Argentina'
   }
   profile {
     label :usage
     name 'Electricity Used'
     path 'energyPerTime'
   }
   output {
     label :co2
     name 'Carbon Dioxide'
     path 'default'
   }
 }