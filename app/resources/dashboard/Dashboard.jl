module Dashboard

using Stipple, StipplePlotly
using Dates
using StatsController
using SearchLight, SearchLightSQLite
using Packages
using OrderedCollections


function plotcomponent(x_val, y_val, name)
  PlotData(
    x = x_val,
    y = y_val,
    plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
    name = name
  )
end


function insert_plot_data(r_stats, model)
  stats = OrderedDict{String,OrderedDict{Date,Int}}()
  totals = Dict{String,Int}()

  for r_stat in r_stats
    haskey(stats, r_stat.package_name) || (stats[r_stat.package_name] = Dict{Date,Int}())
    current_pkg_stats = stats[r_stat.package_name]

    if haskey(current_pkg_stats, r_stat.date)
      current_pkg_stats[r_stat.date] += r_stat.request_count
    else
      current_pkg_stats[r_stat.date] = r_stat.request_count
    end

    stats[r_stat.package_name] = current_pkg_stats
  end

  plot_component_data::Vector{PlotData} = PlotData[]

  for (pkg_name, pkg_data) in stats
    x_val, y_val = String[], Int64[]
    for(download_date, req_count) in pkg_data
      push!(x_val, Dates.format(download_date, "yyyy-mm-dd"))
      push!(y_val, req_count)
    end

    push!(plot_component_data, plotcomponent(x_val, y_val, pkg_name))
    totals[pkg_name] = sum(values(pkg_data) |> collect)
  end

  plot_component_data, totals
end

#== handlers ==#

function handlers(model)
  # triggered when the search form is submitted
  # computes the stets for the requested parameters
  # and renders the results
  on(model.isprocessing) do val
    val || return

    if isempty(model.searchterms[]) || isempty(model.filter_regions[])
      model.isprocessing[] = false

      return
    end

    model.data[], model.totals[] = insert_plot_data(StatsController.search(model.searchterms[],
                                                            model.filter_regions[],
                                                            model.filter_startdate[],
                                                            model.filter_enddate[]),
                                                      model)

    model.isprocessing[] = false
  end

  # triggered when package names are typed
  # if at least 3 letters typed, we search for matching packages
  # and show them as options in the drop down
  on(model.searchterms) do val
    ! isempty(val) && (model.isprocessing[] = true)
  end

  onany(model.filter_startdate, model.filter_enddate, model.filter_regions) do st, ed, reg
    isempty(reg) && (model.filter_regions[] = [ALL_REGIONS])
    length(reg) > 1 && in(ALL_REGIONS, reg) && (model.filter_regions[] = filter(x->x!=ALL_REGIONS, reg))

    model.isprocessing[] = true
  end

  on(model.isready) do val
  end

  model
end

#== reactive model ==#

const ALL_REGIONS = "all"
const REGIONS = String[ALL_REGIONS, "au", "cn-east", "cn-northeast", "cn-southeast", "eu-central", "in", "kr", "sa", "sg", "us-east", "us-west"]
const PACKAGE_NAMES = 
# json file

export Model

@reactive mutable struct Model <: ReactiveModel
  # filter UI
  searchterms::R{Vector{String}} = String[]
  packages::Vector{String} = ["Genie", "Stipple", "Dash", "StippleUI", "SearchLight"]
  options::Vector{String} = []

  filter_startdate::R{Date} = Dates.today() - Dates.Month(3)
  filter_enddate::R{Date} = Dates.today() - Dates.Day(1)

  regions::Vector{String} = REGIONS
  filter_regions::R{Vector{String}} = String[ALL_REGIONS]

  # data for plot
  data::R{Vector{PlotData}} = []
  layout::R{PlotLayout} = PlotLayout(plot_bgcolor = "#fff")

  # downloads totals
  totals::R{Dict{String,Int}} = Dict{String,Int}()
end

Stipple.js_methods(::Model) = raw"""
filterFn (val, update, abort) {
  update(() => {
    const needle = val.toLowerCase()
    if( typeof packageList !== 'undefined' && packageList.length > 0)
      this.options = packageList.filter(v => v.toLowerCase().indexOf(needle) > -1)
    else {
      console.error("`packages.js` missing. Please re-run AutoSearchPackageNamesTask")
      this.options = this.packages
    }
  })
},
setModel (val) {
  model.value = val
}
"""

function factory()
  model = Model |> init |> handlers
end

end