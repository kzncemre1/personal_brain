
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM, pipeline 
from simplet5 import SimpleT5
model = SimpleT5()
model.from_pretrained("mt5","google/mt5-small")

model.train(train_df=train2, # pandas dataframe with 2 columns: source_text & target_text
            eval_df=validation2, # pandas dataframe with 2 columns: source_text & target_text
            source_max_token_len = 512, 
            target_max_token_len = 128,
            batch_size = 8,
            max_epochs = 5,
            use_gpu = True,
            outputdir = "mt5_mlsum_turkish",
            early_stopping_patience_epochs = 0,
            precision = 32
)
