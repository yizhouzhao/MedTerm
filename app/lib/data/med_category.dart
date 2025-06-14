enum MedCategory {
  preview,
  digestive,
  respiratory,
  cardiovascular,
  nervous,
  musculoskeletal,
  integumentary,
  endocrine,
  lymphatic,
  urinary,
  reproductive,
  sensory,
  immune,
  general
}

const Map<MedCategory, String> medCategoryNames = {
  MedCategory.preview: 'Preview',
  MedCategory.digestive: 'Digestive System',
  MedCategory.respiratory: 'Respiratory System',
  MedCategory.cardiovascular: 'Cardiovascular System',
  MedCategory.nervous: 'Nervous System',
  MedCategory.musculoskeletal: 'Musculoskeletal System',
  MedCategory.integumentary: 'Integumentary System',
  MedCategory.endocrine: 'Endocrine System',
  MedCategory.lymphatic: 'Lymphatic System',
  MedCategory.urinary: 'Urinary System',
  MedCategory.reproductive: 'Reproductive System',
  MedCategory.sensory: 'Sensory System',
  MedCategory.immune: 'Immune System',
  MedCategory.general: 'General',
}; 