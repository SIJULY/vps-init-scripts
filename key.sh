# ==========================================
#  SSH Root 登录暴力修复脚本 (增强版)
# ==========================================

# 1. 强制覆盖 Root 的 authorized_keys (换成你的 Key)
mkdir -p /root/.ssh && \
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDuxGi8wfpz+Us1flHLhTFErH0MkejwK68vMomuW1toccSBTl0VK/aTV7zn2KB6B0rWc6cZoK6m02ZW8dieTa4x0CBDl7FxlyqJhOlfyIWJ7/qh3NlEFJ5l/17KeugUYSJxck9rKMsyZgjrPoWQub48CQLFgqxwDNUavAGeJIkxELDTIxPJQNpZOBrAGcQeWNAfwznwOME7lbXPQhPlI26O7gFRA1+9zekwxy3x8/axrr9ygzOLAMgGsK3tM/NF4QHTivrH8Gj8QpkSEVTTEIE2SV2varAgzP3vwwogQ7OSiIW5rr2pdkX9/ZTcVaV9qEDL+GOhcOCkDMbqsF/d/7vt ssh-key-2025-09-27" > /root/.ssh/authorized_keys && \
chmod 700 /root/.ssh && \
chmod 600 /root/.ssh/authorized_keys && \

# 2. 备份 SSH 主配置文件
[ ! -f /etc/ssh/sshd_config.bak ] && cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%F) || true && \

# 3. 移除干扰配置 (Ubuntu/AWS 必须步骤)
rm -f /etc/ssh/sshd_config.d/*.conf 2>/dev/null || true && \

# 4. 修改 SSHD 核心配置 (双重保险禁用密码)
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config && \
sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/g' /etc/ssh/sshd_config && \
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/g' /etc/ssh/sshd_config && \
# 新增：针对新版 OpenSSH 的禁用参数
sed -i 's/^#\?KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/g' /etc/ssh/sshd_config && \

# 5. 确保权限正确
chown -R root:root /root/.ssh && \

# 6. 重启 SSH 服务
(service ssh restart 2>/dev/null || systemctl restart sshd) && \

# 7. 自动验证并输出结果
echo -e "\n✅ 修复完毕！当前配置检查：" && \
echo "-----------------------------------" && \
sudo sshd -T | grep -E "passwordauthentication|permitrootlogin" && \
echo "-----------------------------------" && \
echo "👉 看到 passwordauthentication no 即代表成功禁用密码！"
