## Create user_data 
locals {
    lc_name = "lt${random_string.lab_id.result}"
    ag_name = "ag${random_string.lab_id.result}"

    instance_user_data = <<EOT
#!/bin/bash
# Install the required software 
apt update
apt install -y php libapache2-mod-php mariadb-client php-mysql
cd /var/www/html
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
/usr/local/bin/wp core download --allow-root
/usr/local/bin/wp config create --dbhost=${aws_db_instance.db.endpoint} --dbname=${local.db_name} --dbuser=admin --dbpass='${random_string.lab_id.result}' --allow-root
/usr/local/bin/wp core install --url=${aws_lb.web.arn} --title="Lab ${random_string.lab_id.result}" --admin_user=admin --admin_password='${random_string.lab_id.result}' --admin_email=sales@illumio.com --allow-root
chmod -R 755 wp-content
chown -R  www-data:www-data  wp-content
cat /etc/apache2/apache2.conf |awk '/<Directory \/var\/www\/>/ { mod = 1 } /<\/Directory>/ {mod=0} /AllowOverride None/ && (mod==1) {print "AllowOverride All" ; next } {print}' > /tmp/aconf
mv -f /tmp/aconf /etc/apache2/apache2.conf
echo "Options +FollowSymlinks" > .htaccess
echo "RewriteEngine on" >> .htaccess
echo 'rewriterule ^wp-content/uploads/(.*)$ http://${aws_lb.web.arn}/$1 [r=301,nc]' >> .htaccess
rm -f /var/www/html/index.html
a2enmod rewrite
systemctl restart apache2

EOT

}

resource "aws_key_pair" "kp" {
    key_name   = "labkey-${random_string.lab_id.result}"
    public_key = file("${var.aws_key_pair_pub}.pub")
}

data "aws_ami" "wp_ami" {
    most_recent = true
    name_regex = "^.*ubuntu-focal-20.04-amd64-server-.*"    
    owners = [ "099720109477" ] ## Canonical

    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

## Launch configuration for autoscaling
resource "aws_launch_configuration" "lc_wp" {
    
    name_prefix = local.lc_name
    image_id = data.aws_ami.wp_ami.image_id
    instance_type = "t3.nano"
    user_data = local.instance_user_data
    key_name = aws_key_pair.kp.key_name

    security_groups = [ aws_security_group.web_server.id ] 

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "ag_wp" {
    
    name = local.ag_name
    
    launch_configuration = aws_launch_configuration.lc_wp.id
    max_size = 4 ## Max number of servers in group
    min_size = 2 ## Min number of servers in group
    target_group_arns = [aws_lb_target_group.tg.arn]
    vpc_zone_identifier = module.vpc.public_subnets

    tag {
        key                 = "Name"
        value               = "webserver-${random_string.lab_id.result}"
        propagate_at_launch = true
    }
    tag {
        key                 = "Lab-ID"
        value               = random_string.lab_id.result
        propagate_at_launch = true
    }
}

