data "aws_ssoadmin_instances" "startupco" {}

resource "aws_identitystore_group" "developers" {
  identity_store_id = data.aws_ssoadmin_instances.startupco.identity_store_ids[0]
  display_name      = "Developers"
}

resource "aws_identitystore_group" "operations" {
  identity_store_id = data.aws_ssoadmin_instances.startupco.identity_store_ids[0]
  display_name      = "Operations"
}

resource "aws_identitystore_group" "finance" {
  identity_store_id = data.aws_ssoadmin_instances.startupco.identity_store_ids[0]
  display_name      = "Finance"
}

resource "aws_identitystore_group" "analysts" {
  identity_store_id = data.aws_ssoadmin_instances.startupco.identity_store_ids[0]
  display_name      = "Analysts"
}

resource "aws_identitystore_user" "users" {
  for_each = local.users

  identity_store_id = data.aws_ssoadmin_instances.startupco.identity_store_ids[0]

  user_name    = each.key
  display_name = "${each.value.given_name} ${each.value.family_name}"

  name {
    given_name  = each.value.given_name
    family_name = each.value.family_name
  }
}


locals {
  users = {
    alice = {
      given_name  = "Alice"
      family_name = "Developer"
    }
    bob = {
      given_name  = "Bob"
      family_name = "Developer"
    }
    charlie = {
      given_name  = "Charlie"
      family_name = "Developer"
    }
    dave = {
      given_name  = "Dave"
      family_name = "Developer"
    }
    eve = {
      given_name  = "Eve"
      family_name = "Operations"
    }
    frank = {
      given_name  = "Frank"
      family_name = "Operations"
    }
    grace = {
      given_name  = "Grace"
      family_name = "Finance"
    }
    heidi = {
      given_name  = "Heidi"
      family_name = "Analysts"
    }
    ivan = {
      given_name  = "Ivan"
      family_name = "Analysts"
    }
    judy = {
      given_name  = "Judy"
      family_name = "Analysts"
    }
  }

}

# Operations group memberships
resource "aws_identitystore_group_membership" "eve_operations" {
  identity_store_id = data.aws_ssoadmin_instances.startupco.identity_store_ids[0]

  group_id  = aws_identitystore_group.operations.group_id
  member_id = aws_identitystore_user.users["eve"].user_id
}

resource "aws_identitystore_group_membership" "frank_operations" {
  identity_store_id = data.aws_ssoadmin_instances.startupco.identity_store_ids[0]

  group_id  = aws_identitystore_group.operations.group_id
  member_id = aws_identitystore_user.users["frank"].user_id
}


# Finance group memberships
resource "aws_identitystore_group_membership" "grace_finance" {
  identity_store_id = data.aws_ssoadmin_instances.startupco.identity_store_ids[0]

  group_id  = aws_identitystore_group.finance.group_id
  member_id = aws_identitystore_user.users["grace"].user_id
}


# Analysts group memberships
resource "aws_identitystore_group_membership" "heidi_analysts" {
  identity_store_id = data.aws_ssoadmin_instances.startupco.identity_store_ids[0]

  group_id  = aws_identitystore_group.analysts.group_id
  member_id = aws_identitystore_user.users["heidi"].user_id
}

resource "aws_identitystore_group_membership" "ivan_analysts" {
  identity_store_id = data.aws_ssoadmin_instances.startupco.identity_store_ids[0]

  group_id  = aws_identitystore_group.analysts.group_id
  member_id = aws_identitystore_user.users["ivan"].user_id
}

resource "aws_identitystore_group_membership" "judy_analysts" {
  identity_store_id = data.aws_ssoadmin_instances.startupco.identity_store_ids[0]

  group_id  = aws_identitystore_group.analysts.group_id
  member_id = aws_identitystore_user.users["judy"].user_id
}

# Developer group memberships
resource "aws_identitystore_group_membership" "bob_developer" {
  identity_store_id = data.aws_ssoadmin_instances.startupco.identity_store_ids[0]

  group_id  = aws_identitystore_group.developers.group_id
  member_id = aws_identitystore_user.users["bob"].user_id
}

resource "aws_identitystore_group_membership" "charlie_developer" {
  identity_store_id = data.aws_ssoadmin_instances.startupco.identity_store_ids[0]

  group_id  = aws_identitystore_group.developers.group_id
  member_id = aws_identitystore_user.users["charlie"].user_id
}

resource "aws_identitystore_group_membership" "dave_developer" {
  identity_store_id = data.aws_ssoadmin_instances.startupco.identity_store_ids[0]

  group_id  = aws_identitystore_group.developers.group_id
  member_id = aws_identitystore_user.users["dave"].user_id
}

resource "aws_identitystore_group_membership" "alice_developer" {
  identity_store_id = data.aws_ssoadmin_instances.startupco.identity_store_ids[0]

  group_id  = aws_identitystore_group.developers.group_id
  member_id = aws_identitystore_user.users["alice"].user_id
}


# Permission sets for different roles
resource "aws_ssoadmin_permission_set" "developer_permission" {
  name         = "DeveloperPermission"
  description  = "Permission set for developers"
  instance_arn = data.aws_ssoadmin_instances.startupco.arns[0]
}

resource "aws_ssoadmin_permission_set" "analyst_permission" {
  name         = "AnalystPermission"
  description  = "Permission set for analysts"
  instance_arn = data.aws_ssoadmin_instances.startupco.arns[0]
}

resource "aws_ssoadmin_permission_set" "finance_permission" {
  name         = "FinancePermission"
  description  = "Permission set for finance team"
  instance_arn = data.aws_ssoadmin_instances.startupco.arns[0]
}

resource "aws_ssoadmin_permission_set" "operation_permission" {
  name         = "OperationPermission"
  description  = "Permission set for operations team"
  instance_arn = data.aws_ssoadmin_instances.startupco.arns[0]
}