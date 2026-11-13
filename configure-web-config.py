import re

path = "backend/Web.config"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Remove sameSite="Lax" (not recognized by Mono 6.12 HttpCookies)
content = content.replace('sameSite="Lax"', '')

# 2. Update connection string for docker container db
db_conn = "Data Source=db,1433;Initial Catalog=BSDB2;User Id=sa;Password=BookStore@123456;TrustServerCertificate=True;"
content = re.sub(r'connectionString="[^"]*"', f'connectionString="{db_conn}"', content)

# 3. Default to LocalPickup in docker test environment
content = re.sub(r'<add key="EmailOtpMode" value="[^"]*" />', '<add key="EmailOtpMode" value="LocalPickup" />', content)

# 4. Remove system.codedom so Mono uses its native mcs compiler for Razor views
content = re.sub(r'<system\.codedom>.*?</system\.codedom>', '<!-- system.codedom removed for Mono runtime -->', content, flags=re.DOTALL)

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print("Web.config configured successfully for Docker/Mono.")
