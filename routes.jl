using Genie, Stipple, StippleUI, StipplePlotly
import Dates

using StatsController

#=== config ==#

for m in [Genie, Stipple, StippleUI, StipplePlotly]
  m.assets_config.host = "https://cdn.statically.io/gh/GenieFramework"
end

#== plot data logic ==#

function plotcomponent(x_val, y_val, name)
  PlotData(
    x = x_val,
    y = y_val,
    plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
    name = name
  )
end

function insertplotdata(r_stats, pkg_names)
  all_stats = Dict[]
  for pkg_name in pkg_names

    xy_val = Dict{Date, Int}()

    for r_stat in r_stats                                                 #TODO: n^2 complexity clean it
      if r_stat.package_name == pkg_name
        if haskey(xy_val, r_stat.date)
          xy_val[r_stat.date] = xy_val[r_stat.date] + r_stat.request_count
        else
          xy_val[r_stat.date] = r_stat.request_count
        end
      end
    end
    push!(all_stats, xy_val)
  end

  #TODO: name is not nice. Use type for easy debugging
  my_data = PlotData[]

  for (pkg_name, all_stat) in zip(pkg_names, all_stats)
    new_stat = sort(all_stat)
    
    #TODO: single line assigment
    x_val = String[]
    y_val = Int64[]
     
    #TODO: make these two loops into one
    for key in keys(new_stat)                                             #TODO: n^2 complexity clean it
      push!(x_val, Dates.format(key, "yyyy-mm-dd"))
    end
    
    for val in values(new_stat)
      push!(y_val, val)
    end

    @info push!(my_data, plotcomponent(x_val, y_val, pkg_name))
  end

  return my_data
end

#== reactive model ==#

Base.@kwdef mutable struct Model <: ReactiveModel
  process::R{Bool} = false
  # filter UI
  searchterms::R{Vector{String}} = String[]

  filter_startdate::R{Date} = Dates.today() - Dates.Month(3)
  filter_enddate::R{Date} = Dates.today() - Dates.Month(1)

  #TODO: ask adrian about this. Save database lookup time
  # but also if new region is added make sure to update this
  regions::Vector{String} = String["au","cn-east","cn-northeast","cn-southeast","eu-central","in","kr","sa","sg","us-east","us-west"]
  filter_regions::R{Vector{String}} = String["in"]

  # data for plot
  data::R{Vector{PlotData}} = []

  layout::R{PlotLayout} = PlotLayout(
      plot_bgcolor = "#fff",
      title = PlotLayoutTitle(text="Package downloads", font=Font(24))
    )
  config::R{PlotConfig} = PlotConfig()
end

#== handlers ==#

function handlers(model)
  on(model.searchterms) do searchitems   
    @show searchitems
  end
  on(model.filter_startdate) do startdate
    @show startdate
  end
  on(model.filter_enddate) do enddate
    @show enddate
  end
  on(model.filter_regions) do areas
    @show areas
  end
  on(model.process) do _
    if (model.process[])
      pkgnames::Vector{String} = split((model.searchterms)[1], ", ")
      result_stats = StatsController.search(pkgnames, model.filter_regions[], model.filter_startdate[], model.filter_enddate[])
      model.data[] = insertplotdata(result_stats, pkgnames)
      model.process[] = false
    end
  end
end

#== ui ==#

function ui(model)
  page(
    prepend = """
    <style>
      .rb {
        border-right: 10pt solid #fff;
      }
    </style>
    """,

    vm(model), class="container", [
      heading("PkgStats")

      row([
        cell(class="st-module", [

          row([
            cell([
              textfield("Search for your favourite packages (Hit enter to search)", :searchterms, clearable = true, filled = true)
            ])
          ])

          row([

            cell(class="rb", [
              textfield("Start date", :filter_startdate, clearable = true, filled = true, [
                icon(name="event", class="cursor-pointer", [
                  popup_proxy(cover = true, transitionshow="scale", transitionhide="scale", [
                    datepicker(:filter_startdate, mask = "YYYY-MM-DD")
                  ])
                ])
              ])
            ])

            cell(class="rb", [
              textfield("End date", :filter_enddate, clearable = true, filled = true, [
                icon(name="event", class="cursor-pointer", [
                  popup_proxy(ref="qDateProxy", cover = true, transitionshow="scale", transitionhide="scale", [
                    datepicker(:filter_enddate, mask = "YYYY-MM-DD")
                  ])
                ])
              ])
            ])

            cell([
              select(:filter_regions, options = :regions, multiple = true, clearable = true, filled = true, label = "Region")
            ])

            cell([
              btn("Visualize", type = "submit", loading = :submitting, class = "q-mt-md", color = "teal", @click("process = true"), [
                template("", "v-slot:loading", [
                  spinner(:facebook, wrap = StippleUI.NO_WRAPPER)
                  ])
              ])
            ])
          ])
        ])
      ])

      row([
        cell(class="st-module", [
          h6("Packages downloads over time")
          plot(:data, layout = :layout, config = :config)
        ])
      ])

      row([
        footer([
          h6("Powered by Stipple")
        ])
      ])
    ]
  )
end

#== server ==#

route("/") do
  model = Stipple.init(Model())
  handlers(model)

  html(ui(model), context = @__MODULE__)
end

isrunning(:webserver) || up()