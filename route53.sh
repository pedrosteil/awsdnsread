IDCONTA=$(aws sts get-caller-identity | jq '.[]' | sed -n '2p' | sed 's/^[ \t]*//')
LISTZONES=listHostedZones.txt
ZONAS=zonasHospedadas.txt
IDZONAS=idZonas.txt
NOMEZONAS=nomeZonas.txt
ENDPOINTS=endpoints.txt
REGISTROS=registrosDNS.txt

echo AWS Account: $IDCONTA

echo Listando informações das Zonas no Route53

aws route53 list-hosted-zones > $LISTZONES

# OBTER O ID DA ZONA CADASTRADA NA AWS
cat $LISTZONES | jq '.[] | .[] | {Id}' | grep -v "{" | grep -v "}" | cut -d "\"" -f4 | sed 's/hostedzone//' | sed 's/^..//' > $IDZONAS

# OBTER O NOME DA ZONA CADASTRADA NA AWS
cat $LISTZONES | jq '.[] | .[] | {Name}' | grep -v "{" | grep -v "}" | sed 's/^..//' | cut -d "\"" -f4 > $NOMEZONAS


echo Listando informações dos Registros Route53

# carrega os IDs do arquivo em um array
readarray IDS < ${IDZONAS}

for id in ${IDS[@]}
do
	aws route53 list-resource-record-sets --hosted-zone-id $id >> $REGISTROS;
done

# Obter os nomes dos registros/URLs
cat $REGISTROS | jq '.[] | .[] | {Name}' | cut -d "\"" -f4 | grep -v "{" | grep -v "}" | sed s/.$// | grep -v "^_" | grep -v "\.\_" | grep -v -E "[0-9][0-9][0-9][0-9]" | sort -u > $ENDPOINTS

echo ID das Zonas: $IDZONAS
echo Zonas hospedadas: $NOMEZONAS
echo Registros DNS: $REGISTROS
echo Enpoints: $ENDPOINTS
