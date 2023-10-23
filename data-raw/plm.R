library(VicmapR)

plm <- vicmap_query("open-data-platform:plm25") %>% select(label) %>% collect()

plm_labels <- unique(plm$label)

usethis::use_data(plm_labels)
