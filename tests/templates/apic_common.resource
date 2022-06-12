*** Settings ***
Library   REST   https://%{ACI_URL}   ssl_verify=no
Library   pabot.PabotLib

*** Variables ***
${login_json}   {"aaaUser" : {"attributes" : {"name" : "%{ACI_USERNAME}", "pwd" : "%{ACI_PASSWORD}"}}}

*** Keywords ***
Get APIC Token
    Wait Until Keyword Succeeds   2x   1 minute   POST   /api/aaaLogin.json   ${login_json}
    ${r_token}=   String   $..token
    Set Parallel Value For Key   apic_token   ${r_token[0]}
    Set Suite Variable   ${apic_token}   ${r_token[0]}

Login APIC
    Wait Until Keyword Succeeds   5x   1 s   Acquire Lock   login
    ${apic_token}=   Get Parallel Value For Key   apic_token
    Run Keyword If   "${apic_token}"=="${EMPTY}"   Get APIC Token
    Release Lock   login
    Set Headers   {"Cookie": "APIC-cookie=${apic_token}"}