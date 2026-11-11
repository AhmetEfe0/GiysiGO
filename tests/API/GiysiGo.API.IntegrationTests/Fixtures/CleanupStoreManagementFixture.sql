DELETE o FROM catalog.store_offerings o JOIN catalog.stores s ON s.id = o.store_id WHERE s.corporate_id IN @CorporateIds;
DELETE a FROM [identity].store_assignments a JOIN catalog.stores s ON s.id = a.store_id WHERE s.corporate_id IN @CorporateIds;
DELETE FROM [identity].store_assignments WHERE user_id IN @UserIds;
DELETE FROM [identity].corporate_memberships WHERE corporate_id IN @CorporateIds OR user_id IN @UserIds;
DELETE FROM [identity].user_roles WHERE user_id IN @UserIds;
DELETE FROM catalog.stores WHERE corporate_id IN @CorporateIds;
DELETE FROM [identity].corporates WHERE id IN @CorporateIds;
DELETE FROM [identity].users WHERE id IN @UserIds;
