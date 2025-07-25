-- update_auth_template.sql
-- Cleans up the auth database, creates admin account, and updates the realmlist.

-- Clean up old accounts
DELETE FROM account;
DELETE FROM account_access;

-- Add admin account (username: ADMIN, password: ADMIN)
INSERT INTO account (id, username, sha_pass_hash)
VALUES (1, 'ADMIN', '8301316D0D8448A34FA6D0C6BF1CBFA2B4A1A93A');

INSERT INTO account_access (id, gmlevel, RealmID)
VALUES (1, 3, -1);

-- Update realmlist
DELETE FROM realmlist;

INSERT INTO realmlist (
    id, name, project_shortname, address, port, icon, color, timezone,
    allowedSecurityLevel, population, gamebuild, flag,
    project_hidden, project_enabled, project_dbname, project_dbworld,
    project_dbarchive, project_rates_min, project_rates_max,
    project_transfer_level_max, project_transfer_items,
    project_transfer_skills_spells, project_transfer_glyphs,
    project_transfer_achievements, project_server_same,
    project_server_settings, project_server_remote_path,
    project_accounts_detach, project_setskills_value_max,
    project_chat_enabled, project_statistics_enabled
) VALUES (
    1, '${REALM_NAME}', '${REALM_NAME}', '${REALM_ADDRESS}', ${REALM_PORT},
    ${REALM_ICON}, ${REALM_COLOR}, ${REALM_TIMEZONE},
    ${REALM_SECURITY}, ${REALM_POP}, ${REALM_BUILD}, ${REALM_FLAG},
    0, 1, '', '', '',
    0, 0, 80, 'IGNORE', 'IGNORE', 'IGNORE', 'IGNORE',
    0, '0', '0', 1, 0, 0, 0
);