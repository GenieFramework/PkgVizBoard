using DashboardController, StatsController
using Genie, Stipple, StippleUI, StipplePlotly
using SwagUI, SwaggerMarkdown

#=== config ==#

if Genie.Configuration.isprod()
  for m in [Genie, Stipple, StippleUI, StipplePlotly]
    m.assets_config.host = "https://cdn.statically.io/gh/GenieFramework"
  end
end

#== server ==#

route("/", DashboardController.dashboard)

@swagger """
/api/v1/regions:
  get:
    summary: Get regions
    description: Get regions
    responses:
      '200':
        description: Returns a JSON object with all the regions
"""
route("/api/v1/regions", StatsController.API.V1.regions, method = GET)

@swagger """
/api/v1/packages:
  get:
    summary: Get the list of packages
    description: Get the list of packages
    responses:
      '200':
        description: Returns a JSON object with all the packages
"""
route("/api/v1/packages", StatsController.API.V1.packages, method = GET)

@swagger """
/api/v1/stats:
  get:
    summary: Query the download stats
    description: Query the download stats
    parameters:
      - in: query
        name: packages
        description: A list of package names
        schema:
          type: array
          items:
            type: string
          example: ['Genie', 'Stipple']
      - in: query
        name: regions
        description: A list of regions
        schema:
          type: array
          items:
            type: string
          example: ['eu-central', 'us-west']
      - in: query
        name: startdate
        schema:
          type: string
          format: date
          example: '2021-12-30'
        description: The start date
      - in: query
        name: enddate
        schema:
          type: string
          format: date
          example: '2022-01-15'
        description: The end date
    responses:
      '200':
        description: Returns a JSON object with all the download stats
  post:
    summary: Query the download stats
    description: Query the download stats
    parameters:
      - in: query
        name: packages
        description: A list of package names
        schema:
          type: array
          items:
            type: string
          example: ['Genie', 'Stipple']
      - in: query
        name: regions
        description: A list of regions
        schema:
          type: array
          items:
            type: string
          example: ['eu-central', 'us-west']
      - in: query
        name: startdate
        schema:
          type: string
          format: date
          example: '2021-12-30'
        description: The start date
      - in: query
        name: enddate
        schema:
          type: string
          format: date
          example: '2022-01-15'
        description: The end date
    responses:
      '201':
        description: Returns a JSON object with all the download stats
"""
[route("/api/v1/stats", StatsController.API.V1.search, method = m) for m in [GET, POST]]

@swagger """
/api/v1/badge/{packages}:
  get:
    summary: Get badge
    description: Get badge
    parameters:
      - in: path
        name: packages
        required: true
        schema:
          type: string
          example: 'Genie'
    responses:
      '200':
        description: Returns a badge
"""
route("/api/v1/badge/:packages", StatsController.API.V1.badge, method = GET)

@swagger """
/api/v1/badge/{packages}/{options}:
  get:
    summary: Get badge
    description: Get badge
    parameters:
      - in: path
        name: packages
        required: true
        schema:
          type: string
          example: 'Genie'
      - in: path
        name: options
        required: true
        schema:
          type: string
    responses:
      '200':
        description: Returns a badge
"""
route("/api/v1/badge/:packages/:options", StatsController.API.V1.badge, method = GET, named = :get_api_v1_badge_packages_options)

# build a swagger document from markdown
info = Dict{String, Any}()
info["title"] = "PkgVizBoard API"
info["version"] = "1.0.5"
openApi = OpenAPI("3.0", info)
swagger_document = build(openApi)

options = Options(
  custom_favicon="/favicon.ico", 
  custom_site_title="Package download stats for Julia - Swagger",
  show_explorer=false
)

route("/docs") do 
    render_swagger(swagger_document, options=options)
end
