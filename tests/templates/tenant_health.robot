*** Settings ***
Documentation   Verify Tenant Health
Suite Setup     Login APIC
Default Tags    apic   day2   health   tenants
Resource        ./apic_common.resource

*** Test Cases ***
{% for tenant in apic.tenants | default([]) %}

Verify Tenant {{ tenant.name }} Critical Faults
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/fltCnts.json
    ${critical}=   Get Value From Json   ${r.json()}   $..faultCountsWithDetails.attributes.crit
    Run Keyword If   ${critical}[0] > 0   Run Keyword And Continue On Failure
    ...   Fail  "{{ tenant.name }} has ${critical}[0] critical faults"

Verify Tenant {{ tenant.name }} Health
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/health.json
    ${health}=   Get Value From Json   ${r.json()}   $..healthInst.attributes.cur
    Run Keyword If   ${health}[0] < 100   Run Keyword And Continue On Failure
    ...   Fail  "{{ tenant.name }} health score: ${health}[0]"

{% endfor %}
