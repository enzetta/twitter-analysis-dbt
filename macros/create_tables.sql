CREATE OR REPLACE EXTERNAL TABLE `grounded-nebula-408412.twitter_analysis_raw.ext_epi_netz_de`
OPTIONS (
  format = 'GOOGLE_SHEETS',
  skip_leading_rows = 1,
  max_bad_records = 0,
  uris = ['https://docs.google.com/spreadsheets/d/1Lagm7xzf6I5oducJT1ePrJF33K5l69yBhN_NCzl06kM']
);

-- CREATE OR REPLACE EXTERNAL TABLE `grounded-nebula-408412.twitter_analysis_raw.ext_mdbs_twitter_handles`
-- OPTIONS (
--   format = 'GOOGLE_SHEETS',
--   skip_leading_rows = 1,
--   max_bad_records = 0,
--   uris = ['https://docs.google.com/spreadsheets/d/1A3vFJUY6eKi5YN1AJK_6CUWL5iyzPOA-e_RcBiDFXMc/edit?usp=sharing']
-- );