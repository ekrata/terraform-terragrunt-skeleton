# adds an https listener to the load balancer
# (delete this file if you only want http)

# The port to listen on for HTTPS, always use 443
variable "https_port" {
  default = "443"
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "${var.https_port}"
  protocol          = "HTTPS"
  certificate_arn   = "${aws_acm_certificate.cert.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.main.id}"
  }
}

resource "aws_security_group_rule" "ingress_lb_https" {
  type              = "ingress"
  description       = "HTTPS"
  from_port         = "${var.https_port}"
  to_port           = "${var.https_port}"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.nsg_lb.id}"
}
