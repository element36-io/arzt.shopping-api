# arzt.shopping-api

curl  https://europe-west6-cash36-prod-262508.cloudfunctions.net/testOrders?start_date=2023-01-01 \
-H "x-api-key: demo" \
-H "Content-Type: application/json"

npm run generate-docs
npm run deploy-docs


openapi-generator-cli generate -i api-spec.yaml -g html -o docs --generate-alias-as-model -config openapi-html-config.json


https://openapi-generator.tech/docs/usage/#examples
https://openapi-generator.tech/docs/generators/html

https://roger13.github.io/SwagDefGen/
