if __name__ == "__main__":
    import uvicorn
    from dotenv import load_dotenv

    load_dotenv()

    uvicorn.run(
        "luthor.entrypoints.main_api:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
    )
