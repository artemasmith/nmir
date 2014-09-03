namespace :fias do
  desc "Import all from fias"
  task import: :environment do

    ActiveRecord::Migration.add_column :locations, :aoguid, :string unless 'aoguid'.in? Location.column_names
    ActiveRecord::Migration.add_column :locations, :parentguid, :string unless 'parentguid'.in? Location.column_names


    Rake::Task["fias:generate_local_table_addrobj"].invoke
    Rake::Task["fias:generate_local_table_house"].invoke

    Rake::Task["fias:generate_addrobj"].invoke
    Rake::Task["fias:generate_house"].invoke

    Rake::Task["fias:link_locations"].invoke
    Rake::Task["fias:calc_child_count"].invoke

  end
end