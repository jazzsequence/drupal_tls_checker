#!/usr/bin/env bats
site_id="${SITE_ID:-""}"
pr_num="${PR_NUMBER:-""}"
terminus_token="${TERMINUS_TOKEN}"

@test "Authenticate terminus" {
  run terminus auth:login --machine-token="${terminus_token}"
  [ "$status" -eq 0 ]
}

@test "Enable the module" {
  run terminus drush "${site_id}"."pr-${pr_num}" -- pm:enable tls_checker -y
  [ "$status" -eq 0 ]
}

@test "Run TLS checker on all default folders" {
  run terminus drush "${site_id}"."pr-${pr_num}" -- tls-checker:scan
  echo "Output: $output"
  echo "Site ID: ${site_id}"
  echo "PR number: ${pr_num}"
  echo "Status: $status"
  [ "$status" -eq 0 ]
  [[ "$output" == *"tls-v1-1.badssl.com:1011"* ]]
}

@test "Run TLS data reset" {
  run terminus drush "${site_id}"."pr-${pr_num}" -- tls-checker:reset
  echo "Output: $output"
  echo "Site ID: ${site_id}"
  echo "PR number: ${pr_num}"
  echo "Status: $status"
  [ "$status" -eq 0 ]  
  [[ "$output" == *"TLS scan data reset."* ]]
}

@test "Run TLS checker report on empty data" {
  run terminus drush "${site_id}"."pr-${pr_num}" -- tls-checker:report
  [ "$status" -eq 0 ]  
  [[ "$output" == *"No scan data found."* ]]  
}

@test "Run TLS checker on just custom modules (specified directory)" {
  run terminus drush "${site_id}"."pr-${pr_num}" -- tls-checker:scan --directory=modules/custom
  echo "Output: $output"
  echo "Site ID: ${site_id}"
  echo "PR number: ${pr_num}"
  echo "Status: $status"
  [ "$status" -eq 0 ]
  [[ "$output" == *"tls-v1-1.badssl.com:1011"* ]]    
}

@test "Run TLS checker report" {
  run terminus drush "${site_id}"."pr-${pr_num}" -- tls-checker:report --format=json
    echo "Output: $output"
    echo "Site ID: ${site_id}"
    echo "PR number: ${pr_num}"
    echo "Status: $status"
  [ "$status" -eq 0 ]
  [[ "$output" == *"\"URL\": \"tls-v1-1.badssl.com:1011\""* ]]
}

@test "Check if tls_checker_results table exists" {
  run terminus drush "${site_id}"."pr-${pr_num}" -- sqlq "SHOW TABLES LIKE 'tls_checker_results';"
  echo "Output: $output"
  echo "Site ID: ${site_id}"
  echo "PR number: ${pr_num}"
  echo "Status: $status"
  [ "$status" -eq 0 ]
  [[ "$output" == *"tls_checker_results"* ]]
}

@test "Check if tls_checker_results table contains failing URL" {
  run terminus drush "${site_id}"."pr-${pr_num}" -- sqlq "SELECT * FROM tls_checker_results WHERE url = 'tls-v1-1.badssl.com:1011' AND status = 'failing';"
  echo "Output: $output"
  echo "Site ID: ${site_id}"
  echo "PR number: ${pr_num}"
  echo "Status: $status"
  [ "$status" -eq 0 ]
  [[ "$output" == *"tls-v1-1.badssl.com:1011"* ]]
}

@test "Reset the data and confirm the tls_checker_results table does not exist" {
  terminus drush "${site_id}"."pr-${pr_num}" -- tls-checker:reset
  echo "Output: $output"
  echo "Site ID: ${site_id}"
  echo "PR number: ${pr_num}"
  echo "Status: $status"
  run terminus drush "${site_id}"."pr-${pr_num}" -- sqlq "SELECT * FROM tls_checker_results WHERE url = 'tls-v1-1.badssl.com:1011' AND status = 'failing';"
  [ "$status" -eq 1 ]
}