# arzt.shopping API

Endpoint to read orders of [arzt.shopping](https://hausarzt.shopping/pages/einefueralle).
After you have [registered your location](https://docs.google.com/forms/d/e/1FAIpQLSe__jbfojNWyTDObs5MVVO23xlcmz-eqppRrHuclCTbgpCghg/viewform) you are eligable to  
receive an API key to retrieve your orders via JSON/REST.

Useful links:

* [API documentation](https://element36-io.github.io/arzt.shopping-api/)
* [Sample Response Json](sample-output.json)

Test with Demo data - select "Testarzt (für Softwarehersteller)" on in the
shopping cart of arzt.shopping to experiment wich the interface.

```shell
curl  https://europe-west6-cash36-prod-262508.cloudfunctions.net/testOrders?start_date=2023-03-01 \
-H "x-api-key: demo" \
-H "Content-Type: application/json"
```

Generate documentation - you may change -g html2 with -g html or other targets. 

```shell
openapi-generator-cli generate -i api-spec.yaml -g html -o docs --generate-alias-as-model -config openapi-html-config.json
```

Alternatively with:

```shell
npm run generate-docs
npm run deploy-docs
```

Useful links for development:

[OpenAPI generator](https://openapi-generator.tech/docs/usage/#examples)
[OpenAPI Html generator](https://openapi-generator.tech/docs/generators/html)
[Schema generator](https://roger13.github.io/SwagDefGen/)
