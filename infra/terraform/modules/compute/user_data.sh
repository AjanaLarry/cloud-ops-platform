#!/bin/bash
dnf update -y
dnf install -y nginx
systemctl start nginx
systemctl enable nginx

cat > /usr/share/nginx/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
  <title>cloud-ops-platform</title>
  <style>
    body { font-family: monospace; background: #0d1117; color: #58a6ff;
           display: flex; align-items: center; justify-content: center;
           height: 100vh; margin: 0; }
    .box { text-align: center; border: 1px solid #30363d;
           padding: 40px; border-radius: 8px; }
    h1 { font-size: 2rem; margin-bottom: 8px; }
    p  { color: #8b949e; margin: 4px 0; }
  </style>
</head>
<body>
  <div class="box">
    <h1>cloud-ops-platform</h1>
    <p>EC2 · ca-central-1 · Week 3 · Terraform ✓</p>
    <p>nginx is running</p>
  </div>
</body>
</html>
HTML

echo "User data complete: $(date)" >> /var/log/user-data.log
