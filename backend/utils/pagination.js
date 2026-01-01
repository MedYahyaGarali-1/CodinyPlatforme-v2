/**
 * Pagination utility for API endpoints
 * Provides consistent pagination across all endpoints
 */

class PaginationHelper {
  /**
   * Get pagination parameters from request
   * @param {Object} query - Express request query object
   * @returns {Object} - { page, limit, offset }
   */
  static getPaginationParams(query) {
    const page = Math.max(1, parseInt(query.page) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(query.limit) || 10)); // Max 100 items per page
    const offset = (page - 1) * limit;

    return { page, limit, offset };
  }

  /**
   * Format paginated response
   * @param {Array} data - Data items
   * @param {number} totalCount - Total count of items
   * @param {number} page - Current page
   * @param {number} limit - Items per page
   * @returns {Object} - Formatted pagination response
   */
  static formatResponse(data, totalCount, page, limit) {
    const totalPages = Math.ceil(totalCount / limit);

    return {
      data,
      pagination: {
        currentPage: page,
        totalPages,
        totalItems: totalCount,
        itemsPerPage: limit,
        hasNextPage: page < totalPages,
        hasPreviousPage: page > 1,
      },
    };
  }

  /**
   * Get SQL pagination clause
   * @param {number} limit - Items per page
   * @param {number} offset - Offset for pagination
   * @returns {string} - SQL LIMIT and OFFSET clause
   */
  static getSqlClause(limit, offset) {
    return `LIMIT ${limit} OFFSET ${offset}`;
  }
}

module.exports = PaginationHelper;
