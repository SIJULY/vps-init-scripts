# 1. 部署公钥 (创建目录 -> 写入Key -> 设置权限)
mkdir -p /root/.ssh && \
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDuxGi8wfpz+Us1flHLhTFErH0MkejwK68vMomuW1toccSBTl0VK/aTV7zn2KB6B0rWc6cZoK6m02ZW8dieTa4x0CBDl7FxlyqJhOlfyIWJ7/qh3NlEFJ5l/17KeugUYSJxck9rKMsyZgjrPoWQub48CQLFgqxwDNUavAGeJIkxELDTIxPJQNpZOBrAGcQeWNAfwznwOME7lbXPQhPlI26O7gFRA1+9zekwxy3x8/axrr9ygzOLAMgGsK3tM/NF4QHTivrH8Gj8QpkSEVTTEIE2SV2varAgzP3vwwogQ7OSiIW5rr2pdkX9/ZTcVaV9qEDL+GOhcOCkDMbqsF/d/7vt ssh-key-2025-09-27" >> /root/.ssh/authorized_keys && \
chmod 700 /root/.ssh && \
chmod 600 /root/.ssh/authorized_keys && \

# 2. 备份 SSH 配置文件
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%F) && \

# 3. 修改配置：开启公钥验证
sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/g' /etc/ssh/sshd_config && \

# 4. 修改配置：禁止密码验证 (包括 Root 和普通用户)
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/g' /etc/ssh/sshd_config && \

# 5. 修改配置：Root 仅限密钥登录
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config && \

# 6. 重启 SSH 服务生效
(service ssh restart 2>/dev/null || systemctl restart sshd) && \

# 7. 输出成功提示
echo -e "\n✅ 大功告成！\n1. 公钥已添加。\n2. 密码登录已彻底关闭。\n3. SSH 服务已重启。\n👉 请新开一个窗口测试连接！"
