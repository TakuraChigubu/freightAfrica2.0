const { query } = require('../config/database');
const { logger } = require('./logger');

const selectOne = async (table, where) => {
  const whereClause = Object.entries(where)
    .map(([key, _], index) => `${key} = $${index + 1}`)
    .join(' AND ');

  const sql = `SELECT * FROM ${table} WHERE ${whereClause} LIMIT 1`;
  const params = Object.values(where);

  const result = await query(sql, params);
  return result.rows[0] || null;
};

const selectAll = async (table, where = {}, limit = null, offset = 0) => {
  let sql = `SELECT * FROM ${table}`;
  const params = [];

  if (Object.keys(where).length > 0) {
    const whereClause = Object.entries(where)
      .map(([key, _], index) => `${key} = $${index + 1}`)
      .join(' AND ');
    sql += ` WHERE ${whereClause}`;
    params.push(...Object.values(where));
  }

  if (limit) {
    sql += ` LIMIT $${params.length + 1}`;
    params.push(limit);
  }

  if (offset) {
    sql += ` OFFSET $${params.length + 1}`;
    params.push(offset);
  }

  const result = await query(sql, params);
  return result.rows;
};

const insert = async (table, data) => {
  const keys = Object.keys(data);
  const values = Object.values(data);
  const placeholders = keys.map((_, index) => `$${index + 1}`).join(',');

  const sql = `INSERT INTO ${table} (${keys.join(',')}) VALUES (${placeholders}) RETURNING *`;
  const result = await query(sql, values);
  return result.rows[0];
};

const update = async (table, data, where) => {
  const setClause = Object.entries(data)
    .map(([key, _], index) => `${key} = $${index + 1}`)
    .join(', ');

  const whereClause = Object.entries(where)
    .map(([key, _], index) => `${key} = $${Object.keys(data).length + index + 1}`)
    .join(' AND ');

  const sql = `UPDATE ${table} SET ${setClause}, updated_at = CURRENT_TIMESTAMP WHERE ${whereClause} RETURNING *`;
  const params = [...Object.values(data), ...Object.values(where)];

  const result = await query(sql, params);
  return result.rows[0] || null;
};

const softDelete = async (table, where) => {
  return update(table, { is_deleted: true, deleted_at: new Date() }, where);
};

const hardDelete = async (table, where) => {
  const whereClause = Object.entries(where)
    .map(([key, _], index) => `${key} = $${index + 1}`)
    .join(' AND ');

  const sql = `DELETE FROM ${table} WHERE ${whereClause}`;
  const params = Object.values(where);

  const result = await query(sql, params);
  return result.rowCount;
};

module.exports = {
  selectOne,
  selectAll,
  insert,
  update,
  softDelete,
  hardDelete,
};