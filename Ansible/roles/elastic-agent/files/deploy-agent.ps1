param(
    [Parameter(Mandatory)] $Password,
    [Parameter(Mandatory)] $ServerIP
)

# Prepare headers for authentication
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("elastic:$Password"))
$Headers = @{
    Authorization = "Basic $encodedCreds"
}

# Disable certificate check
Add-Type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@ -ea SilentlyContinue -wa SilentlyContinue    
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Get elastic version to download the righ agent
$ElasticVersion=(Invoke-WebRequest -UseBasicParsing -Uri "https://${ServerIP}:9200" -Headers $Headers).Content | ConvertFrom-Json | Select-Object -ExpandProperty version | Select-Object -ExpandProperty number
# Get the enrollment token
$EnrollmentToken=(Invoke-WebRequest -UseBasicParsing -Uri "http://${ServerIP}/api/fleet/enrollment_api_keys" -Headers $Headers).Content | ConvertFrom-Json | Select-Object -ExpandProperty items | Select-Object -ExpandProperty api_key -first 1

# Download and install the agent
cd $env:Temp
wget https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-$ElasticVersion-windows-x86_64.zip -OutFile elastic-agent-$ElasticVersion-windows-x86_64.zip

Expand-Archive -Path elastic-agent-$ElasticVersion-windows-x86_64.zip -DestinationPath . -Force
cd elastic-agent-$ElasticVersion-windows-x86_64
.\elastic-agent.exe install --url=https://${ServerIP}:8220 --enrollment-token=$EnrollmentToken --force --insecure

