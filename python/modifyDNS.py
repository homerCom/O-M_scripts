import requests

#Kiosoft
api_token = 'ka_r5lBb24sf8gmSEbHD0f8ftrMtdx2uOKAjOK-P'
zone_id = 'e710bb241870f794c6f90d521e39dade'

domain_names = ['test1.vaststar.net', 'test2.vaststar.net']
new_cname_value = 'tm03-prod-cleanstore.trafficmanager.net'

headers = {
    'Authorization': f'Bearer {api_token}',
    'Content-Type': 'application/json',
}

for domain_name in domain_names:
    print(domain_name)
    url = f'https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records?type=A&name={domain_name}'
    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        data = response.json()
        if data['result']:
            record_id = data['result'][0]['id']

            update_data = {
                'type': 'CNAME',
                'name': domain_name,
                'content': new_cname_value,
            }

            update_url = f'https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records/{record_id}'
            response = requests.put(update_url, json=update_data, headers=headers)

            if response.status_code == 200:
                print(f'Successfully updated {domain_name} A record to CNAME with content: {new_cname_value}')
            else:
                print(f'Failed to update {domain_name} A record. Status code: {response.status_code}')
        else:
            print(f'No A records found for {domain_name}')
    else:
        print(f'Failed to retrieve DNS records for {domain_name}. Status code: {response.status_code}')

