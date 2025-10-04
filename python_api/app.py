from flask import Flask, request, jsonify
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM, pipeline
import torch

app = Flask(__name__)


#Text-To-Text Transfer Transformer

# Türkçe modeller
ozcan_model_name = "ozcangundes/mt5-small-turkish-summarization"
mukayese_model_name = "mukayese/mt5-base-turkish-summarization"

# Tokenizer ve modeller
ozcan_tokenizer = AutoTokenizer.from_pretrained(ozcan_model_name, use_fast=False)

'''

use_fast = False kısmı python tabanlı tokenizer kullanılacak demek, true olursa rust tabanlı. Python daha uyumlu çalışıyor ama daha yavaş

'''
ozcan_model = AutoModelForSeq2SeqLM.from_pretrained(ozcan_model_name)

mukayese_tokenizer = AutoTokenizer.from_pretrained(mukayese_model_name, use_fast=False)
mukayese_model = AutoModelForSeq2SeqLM.from_pretrained(mukayese_model_name) # modelin sıfırdan eğitildikten sonra kazandığı ağırlıklardır

# İngilizce model
en_summarizer = pipeline("summarization", model="sshleifer/distilbart-cnn-12-6")

# Özetleme fonksiyonu
def summarize_turkish(text, tokenizer, model):
    inputs = tokenizer( # Metin sayılara çeviriliyor.
        text,
        max_length=1024,
        padding="max_length", # eğer metin kısa ise kalanı doldurulur
        truncation=True, # Çok uzun metinleri keser
        return_attention_mask=True, #Dikkat maskesi ekler (nerelere odaklanacak)
        add_special_tokens=True, #  modelin metnin nerede başladığını, nerede bittiğini, hangi görevde olduğunu anlamasını sağlar.
        return_tensors="pt"
    )

    with torch.no_grad(): # geriye dönük hata hesaplaması yapılmaz
        generated_ids = model.generate(
            input_ids=inputs["input_ids"], #modelin giriş token dizisi
            attention_mask=inputs["attention_mask"], #modelin hangi tokenlere dikkat edeceğini belirten maske
            num_beams=4, # beam search ışn sayısı, en iyi sonucu bulmak için olası çıkışları arar
            max_length=300, # output için 
            
            repetition_penalty=2.5, #aynı kelimelerin kullanımını zorlaştırır, ceza mekanizmasıdır
            no_repeat_ngram_size=3,# tekrar eden keimeler için ceza
            length_penalty=0.8, # 	Daha kısa özetleri tercih etmeye zorlar
            early_stopping=False,
            use_cache=True
        )

    summary = tokenizer.decode(generated_ids[0], skip_special_tokens=True, clean_up_tokenization_spaces=True)
    return summary

# 🔹 Başlık üretimi
def generate_title(summary_text, max_words=3):
    return ' '.join(summary_text.split()[:max_words])

# 🔹 API endpoint
@app.route('/summarize', methods=['POST'])
def summarize_text():
    #json platform bağımsız ddosya formatı
    data = request.get_json()
    text = data.get("text", "")
    model_choice = data.get("model", "ozcan")  # Default model: ozcan

    if not text:
        return jsonify({"error": "No text provided"}), 400

    try:
        if model_choice == "ozcan":
            summary_text = summarize_turkish(text, ozcan_tokenizer, ozcan_model)
        elif model_choice == "mukayese":
            summary_text = summarize_turkish(text, mukayese_tokenizer, mukayese_model)
        elif model_choice == "english":
            result = en_summarizer(text, max_length=60, min_length=10, do_sample=False)
            summary_text = result[0]["summary_text"]
        else:
            return jsonify({"error": "Invalid model selected."}), 400
    except Exception as e:
        return jsonify({"error": f"Özetleme hatası: {str(e)}"}), 500

    title = generate_title(summary_text, max_words=3)
    return jsonify({
        "summary": summary_text,
        "title": title
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
